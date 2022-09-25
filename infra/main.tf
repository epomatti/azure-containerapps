terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "0.6.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

### Locals ###

locals {
  project = "microservices"
}

### Group ###

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.project}"
  location = var.location
}

### VNet ###

resource "azurerm_network_security_group" "default" {
  name                = "nsg-${local.project}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${local.project}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "runtime" {
  name                 = "subnet-runtime"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "infrastructure" {
  name                 = "subnet-infrastructure"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.90.0.0/16"]
}

### Service Bus ###

resource "azurerm_servicebus_namespace" "default" {
  name                = "bus-${local.project}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Standard is required for Dapr to use topics
  sku = "Standard"
}

resource "azurerm_servicebus_topic" "default" {
  name                = "orders"
  namespace_id        = azurerm_servicebus_namespace.default.id
  enable_partitioning = true
}


### Log Analytics Workspace ###

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.project}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "default" {
  name                = "appi-${local.project}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.default.id
}

### Container Apps - Environment ###

resource "azapi_resource" "managed_environment" {
  name      = "env-${local.project}"
  location  = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  type      = "Microsoft.App/managedEnvironments@2022-03-01"

  body = jsonencode({
    properties = {
      daprAIInstrumentationKey = azurerm_application_insights.default.instrumentation_key
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.default.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.default.primary_shared_key
        }
      }
      vnetConfiguration = {
        internal               = false
        runtimeSubnetId        = azurerm_subnet.runtime.id
        infrastructureSubnetId = azurerm_subnet.infrastructure.id
      }
    }
  })

}

### Application Apps - Services ###

module "containerapp_order" {
  source = "./modules/containerapp"

  # Container App
  name        = "app-order"
  location    = var.location
  group_id    = azurerm_resource_group.default.id
  environment = azapi_resource.managed_environment.id

  # Ingress
  external            = true
  ingress_target_port = 3000

  # Dapr
  dapr_appId   = "order"
  dapr_appPort = 3000

  # Container
  container_image = "epomatti/azure-containerapps-order"
  container_envs = [
    { name = "DAPR_APP_PORT", value = "3000" },
    { name = "DAPR_HTTP_PORT", value = "3500" }
  ]
}

module "containerapp_delivery" {
  source = "./modules/containerapp"

  # Container App
  name        = "app-delivery"
  location    = var.location
  group_id    = azurerm_resource_group.default.id
  environment = azapi_resource.managed_environment.id

  # Ingress
  external            = false
  ingress_target_port = 3100

  # Dapr
  dapr_appId   = "delivery"
  dapr_appPort = 3100

  # Container
  container_image = "epomatti/azure-containerapps-delivery"
  container_envs = [
    { name = "DAPR_APP_PORT", value = "3100" },
    { name = "DAPR_HTTP_PORT", value = "3500" }
  ]
}

### Dapr ###
module "dapr_pubsub" {
  source                       = "./modules/dapr-pubsub"
  environment                  = azapi_resource.managed_environment.id
  servicebus_connection_string = azurerm_servicebus_namespace.default.default_primary_connection_string
}

### Nginx ###

module "nginx" {
  source      = "./modules/nginx"
  location    = var.location
  group_id    = azurerm_resource_group.default.id
  environment = azapi_resource.managed_environment.id
}

### Outputs ###

output "order_url" {
  value = "https://${module.containerapp_order.fqdn}"
}

output "nginx_url" {
  value = "https://${module.nginx.fqdn}"
}
