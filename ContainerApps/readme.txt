#Solution file in dir app!

docker build -t 10gler/testrepo:v1.0 .

docker tag azurecontainerdemo:dev 10gler/testrepo:v1.0

docker push 10gler/testrepo:v1.0

az containerapp update --name tgrazurecontainerdemo --resource-group tgrtmp --image 10gler/testrepo:v1.1