terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "0.6.0"
    }
  }
}

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
