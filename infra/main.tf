terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
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
  name                = "nsg-microservices"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet-microservices"
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
  sku                 = "Basic"
}

resource "azurerm_servicebus_queue" "default" {
  name                = "queue1"
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
  name                = "appi-services"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.default.id
}

### Container Apps - Environment ###

resource "azapi_resource" "managed_environment" {
  name      = "environment-${local.project}"
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

### Dapr ###

resource "azapi_resource" "dapr_servicebus" {
  name      = "messages-pub-sub"
  parent_id = azapi_resource.managed_environment.id
  type      = "Microsoft.App/managedEnvironments/daprComponents@2022-03-01"

  // TODO: Implement Azure Authentication
  body = jsonencode({
    properties = {
      componentType = "pubsub.azure.servicebus"
      version       = "v1"
      initTimeout   = 60
      metadata = [
        {
          name      = "connectionString",
          secretRef = "primaryConnectionString"
        }
      ]
      secrets = [
        {
          name  = "primaryConnectionString",
          value = azurerm_servicebus_namespace.default.default_primary_connection_string
        }
      ]
      scopes = [
        "publisher-app",
        "subscriber-app"
      ]
    }
  })
}


### Application Apps - Services ###

resource "azapi_resource" "service1" {
  name      = "capps-service1"
  location  = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  type      = "Microsoft.App/containerApps@2022-03-01"

  response_export_values = ["properties.configuration.ingress.fqdn"]

  body = jsonencode({
    properties : {
      managedEnvironmentId = azapi_resource.managed_environment.id
      configuration = {
        ingress = {
          external   = true
          targetPort = 3000
        }
        dapr = {
          enabled     = true
          appId       = "publisher-app"
          appPort     = 3500
          appProtocol = "http"
        }
      }
      template = {
        containers = [
          {
            name  = "service1"
            image = "epomatti/azure-containerapps-service1"
            resources = {
              cpu    = 0.5
              memory = "1.0Gi"
            }
            env = [
              { name = "SERVICE2_URL", value = "https://${jsondecode(azapi_resource.service2.output).properties.configuration.ingress.fqdn}" }
            ]
            probes = [
              {
                type = "Liveness"
                httpGet = {
                  path = "/liveness"
                  port = 3000
                  httpHeaders = [
                    {
                      name  = "Custom-Header"
                      value = "Awesome"
                    }
                  ]
                }
                initialDelaySeconds = 3
                periodSeconds       = 3
              }
            ]
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 2
        }
      }
    }
  })
}

resource "azapi_resource" "service2" {
  name      = "capps-service2"
  location  = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  type      = "Microsoft.App/containerApps@2022-03-01"

  response_export_values = ["properties.configuration.ingress.fqdn"]

  body = jsonencode({
    properties : {
      managedEnvironmentId = azapi_resource.managed_environment.id
      configuration = {
        ingress = {
          external   = false
          targetPort = 3100
        }
        dapr = {
          enabled     = true
          appId       = "subscriber-app"
          appPort     = 3501
          appProtocol = "http"
        }
      }
      template = {
        containers = [
          {
            name  = "service2"
            image = "epomatti/azure-containerapps-service2"
            resources = {
              cpu    = 0.5
              memory = "1.0Gi"
            }
            probes = [
              {
                type = "Liveness"
                httpGet = {
                  path = "/liveness"
                  port = 3100
                  httpHeaders = [
                    {
                      name  = "Custom-Header"
                      value = "Awesome"
                    }
                  ]
                }
                initialDelaySeconds = 3
                periodSeconds       = 3
              }
            ]
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 2
        }
      }
    }
  })
}


### Nginx Container ###

resource "azapi_resource" "nginx" {
  name      = "capps-nginx"
  location  = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  type      = "Microsoft.App/containerApps@2022-03-01"

  response_export_values = ["properties.configuration.ingress.fqdn"]

  body = jsonencode({
    properties : {
      managedEnvironmentId = azapi_resource.managed_environment.id
      configuration = {
        ingress = {
          external   = true
          targetPort = 80
        }
      }
      template = {
        containers = [
          {
            name  = "nginx"
            image = "nginx"
            resources = {
              cpu    = 0.5
              memory = "1.0Gi"
            }
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 2
        }
      }
    }
  })
}

### Outputs ###

output "service1_fqdn" {
  value = "https://${jsondecode(azapi_resource.service1.output).properties.configuration.ingress.fqdn}"
}

output "service2_fqdn" {
  value = "https://${jsondecode(azapi_resource.service2.output).properties.configuration.ingress.fqdn}"
}

output "nginx_fqdn" {
  value = "https://${jsondecode(azapi_resource.nginx.output).properties.configuration.ingress.fqdn}"
}
