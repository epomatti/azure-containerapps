resource "azapi_resource" "dapr_servicebus" {
  name      = "messages-pub-sub"
  parent_id = var.environment
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
          value = var.servicebus_connection_string
        }
      ]
      scopes = [
        "publisher",
        "subscriber"
      ]
    }
  })
}