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

resource "azapi_resource" "container_app" {
  name      = var.name
  location  = var.location
  parent_id = var.group
  type      = "Microsoft.App/containerApps@2022-03-01"

  response_export_values = ["properties.configuration.ingress.fqdn"]

  body = jsonencode({
    properties : {
      managedEnvironmentId = var.environment
      configuration = {
        ingress = {
          external   = var.external
          targetPort = var.ingress_target_port
        }
        dapr = {
          enabled     = true
          appId       = var.dapr_appId
          appPort     = var.dapr_appPort
          appProtocol = "http"
        }
      }
      template = {
        containers = [
          {
            name  = var.name
            image = var.container_image
            resources = {
              cpu    = 0.5
              memory = "1.0Gi"
            }
            env = var.container_envs
            probes = [
              {
                type = "Liveness"
                httpGet = {
                  path = "/liveness"
                  port = var.ingress_target_port
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
