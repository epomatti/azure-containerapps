# azure-containerapps

Serverless micro-services on Azure with Container Apps.

As per Microsoft [documentation](https://learn.microsoft.com/en-us/azure/container-apps/connect-apps?tabs=bash) on networking for Container Apps:

> When you call another container in the same environment using the FQDN, the network traffic never leaves the environment.

## Deploy

Simply run the following to start the environment:

```sh
cd infra

touch .auto.tfvars

terraform init
terraform apply -auto-approve
```
## Local Dapr

```sh
docker run -d -p 5672:5672 --name dtc-rabbitmq rabbitmq
dapr run --app-id service2 --app-port 3100 --components-path ./myComponents
```

```sh
dapr run --app-id service1 --dapr-http-port 3601
dapr publish --publish-app-id service2 --pubsub messages-pub-sub --topic queue1 --data 'awsome'
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

docker build ./service1 -t epomatti/azure-containerapps-service1
docker build ./service2 -t epomatti/azure-containerapps-service2

docker login --username=<username>

docker push epomatti/azure-containerapps-service1
docker push epomatti/azure-containerapps-service2
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
- [Microsoft Tech Community Article - Terraform](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/can-i-create-an-azure-container-apps-in-terraform-yes-you-can/ba-p/3570694)
- [Terraform Article](https://www.thorsten-hans.com/deploy-azure-container-apps-with-terraform/)

