terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "0.6.0"
    }
  }
}

variable "environment" {
  type = string
}

variable "servicebus_connection_string" {
  type      = string
  sensitive = true
}

resource "azapi_resource" "dapr_servicebus" {
  name      = "order-pub-sub"
  parent_id = var.environment
  type      = "Microsoft.App/managedEnvironments/daprComponents@2022-03-01"

  // TODO: Implement Azure Authentication
  body = jsonencode({
    properties = {
      componentType = "pubsub.azure.servicebus"
      version       = "v1"
      initTimeout   = "60"
      metadata = [
        {
          name      = "connectionString",
          secretRef = "primary-connection-string"
        }
      ]
      secrets = [
        {
          name  = "primary-connection-string",
          value = var.servicebus_connection_string
        }
      ]
      scopes = [
        "order",
        "delivery"
      ]
    }
  })
}
