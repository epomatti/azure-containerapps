terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "0.6.0"
    }
  }
}

variable "location" {
  type = string
}

variable "group_id" {
  type = string
}

variable "environment" {
  type = string
}

resource "azapi_resource" "nginx" {
  name      = "app-nginx"
  location  = var.location
  parent_id = var.group_id
  type      = "Microsoft.App/containerApps@2022-03-01"

  response_export_values = ["properties.configuration.ingress.fqdn"]

  body = jsonencode({
    properties : {
      managedEnvironmentId = var.environment
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

output "fqdn" {
  value = jsondecode(azapi_resource.nginx.output).properties.configuration.ingress.fqdn
}
