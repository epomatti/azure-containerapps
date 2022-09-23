# azure-containerapps

Azure Container Apps environment



```sh
docker-compose build
docker-compose up
```

Pushing images to DockerHub

```sh
docker build ./service1 -t epomatti/azure-containerapps-service1
docker build ./service2 -t epomatti/azure-containerapps-service2

docker login --username=<username>

docker push epomatti/azure-containerapps-service1
docker push epomatti/azure-containerapps-service2
```

As per Microsoft [documentation](https://learn.microsoft.com/en-us/azure/container-apps/connect-apps?tabs=bash) on networking for Container Apps:

> When you call another container in the same environment using the FQDN, the network traffic never leaves the environment.

- [Container Apps REST API - Container Apps](https://learn.microsoft.com/en-us/rest/api/containerapps/container-apps/create-or-update?tabs=HTTP)
- [Container Apps REST API - Managed Environments](https://learn.microsoft.com/en-us/rest/api/containerapps/managed-environments/create-or-update?tabs=HTTP)

https://techcommunity.microsoft.com/t5/fasttrack-for-azure/can-i-create-an-azure-container-apps-in-terraform-yes-you-can/ba-p/3570694

https://www.thorsten-hans.com/deploy-azure-container-apps-with-terraform/

