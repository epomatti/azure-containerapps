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




https://techcommunity.microsoft.com/t5/fasttrack-for-azure/can-i-create-an-azure-container-apps-in-terraform-yes-you-can/ba-p/3570694

https://www.thorsten-hans.com/deploy-azure-container-apps-with-terraform/

