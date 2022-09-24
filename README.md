# azure-containerapps

Serverless micro-services on Azure with Container Apps.

As per Microsoft [documentation](https://learn.microsoft.com/en-us/azure/container-apps/connect-apps?tabs=bash) on networking for Container Apps:

> When you call another container in the same environment using the FQDN, the network traffic never leaves the environment.

## Deploy

Register these providers if they have never been used:

```sh
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
```

Simply run the following to start the environment:

```sh
cd infra

touch .auto.tfvars

terraform init
terraform apply -auto-approve
```
## Self-Hosted Dapr

Start the services:

```sh
# Start RabbitMQ
docker run -d -p 5672:5672 --name dtc-rabbitmq rabbitmq

# Subscriber web server
cd subscriber
npm start

# Subscriber Dapr
dapr run \
  --app-port 3100 \
  --app-id subscriber \
  --app-protocol http \
  --dapr-http-port 3501 \
  --components-path ./components

# Publisher Dapr
dapr run \
  --app-id publisher \
  --app-protocol http \
  --dapr-http-port 3500 \
  --components-path ./components

# Publisher Web Server
cd publisher
npm start
```

To test it, send a message to the queue:

```sh
http://localhost:3000/api/enqueue
```

## Local Development & Docker

You can run each of the services independently by cd-ing into each one and using basic Node commands:

```sh
npm install
npm start
```

For an integrated local development experience:

```sh
cd services

docker-compose build
docker-compose up
```

To publish container changes:

```sh
cd services

docker build ./publisher -t epomatti/azure-containerapps-publisher
docker build ./subscriber -t epomatti/azure-containerapps-subscriber

docker login --username=<username>

docker push epomatti/azure-containerapps-publisher
docker push epomatti/azure-containerapps-subscriber
```

Testing in isolation:

```sh
docker container run --name containerapps-subscriber -p 3100:3100 -d --rm epomatti/azure-containerapps-subscriber
```

## Clean-up

```sh
terraform destroy -auto-approve
```


## References

- [Container Apps REST API - Container Apps](https://learn.microsoft.com/en-us/rest/api/containerapps/container-apps/create-or-update?tabs=HTTP)
- [Container Apps REST API - Managed Environments](https://learn.microsoft.com/en-us/rest/api/containerapps/managed-environments/create-or-update?tabs=HTTP)
- [Dapr Service Bus](https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-azure-servicebus/)
- [Dapr Pub/Sub](https://docs.dapr.io/developing-applications/building-blocks/pubsub/howto-publish-subscribe/)
- [Microservices with Dapr using the CLI](https://learn.microsoft.com/en-us/azure/container-apps/microservices-dapr?tabs=bash)
- [Microsoft Tech Community Article - Terraform](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/can-i-create-an-azure-container-apps-in-terraform-yes-you-can/ba-p/3570694)
- [Terraform Article](https://www.thorsten-hans.com/deploy-azure-container-apps-with-terraform/)
