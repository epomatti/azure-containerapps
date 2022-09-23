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


### Log Analytics Workspace ###

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.project}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
}

resource "azapi_resource" "managed_environment" {
  name      = "${local.project}-managed-environment"
  location  = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  type      = "Microsoft.App/managedEnvironments@2022-03-01"

  body = jsonencode({
    properties = {
      # daprAIInstrumentationKey = var.instrumentation_key
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.default.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.default.primary_shared_key
        }
      }
    }
  })

}


### Services ###

# resource "azapi_resource" "container_app" {
#   name      = "capps-service1"
#   location  = azurerm_resource_group.default.location
#   parent_id = azurerm_resource_group.default.id
#   type      = "Microsoft.App/containerApps@2022-03-01"

#   body = jsonencode({
#     properties : {
#       managedEnvironmentId = azapi_resource.managed_environment.id
#       configuration = {
#         ingress = {
#           external   = true
#           targetPort = 3000
#         }
#       }
#       template = {
#         containers = [
#           {
#             name  = "service1"
#             image = "epomatti/azure-containerapps-service1"
#             resources = {
#               cpu    = 0.5
#               memory = "1.0Gi"
#             }
#           }
#         ]
#         scale = {
#           minReplicas = 1
#           maxReplicas = 2
#         }
#       }
#     }
#   })
# }

# resource "azapi_resource" "container_app" {
#   name      = "capps-service2"
#   location  = azurerm_resource_group.default.location
#   parent_id = azurerm_resource_group.default.id
#   type      = "Microsoft.App/containerApps@2022-03-01"

#   body = jsonencode({
#     properties : {
#       managedEnvironmentId = azapi_resource.managed_environment.id
#       configuration = {
#         ingress = {
#           external   = true
#           targetPort = 3100
#         }
#       }
#       template = {
#         containers = [
#           {
#             name  = "service2"
#             image = "epomatti/azure-containerapps-service2"
#             resources = {
#               cpu    = 0.5
#               memory = "1.0Gi"
#             }
#           }
#         ]
#         scale = {
#           minReplicas = 1
#           maxReplicas = 2
#         }
#       }
#     }
#   })
# }


### Nginx Container ###

resource "azapi_resource" "container_app" {
  name      = "capps-nginx"
  location  = azurerm_resource_group.default.location
  parent_id = azurerm_resource_group.default.id
  type      = "Microsoft.App/containerApps@2022-03-01"

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
