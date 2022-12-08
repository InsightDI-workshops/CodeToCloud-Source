#!/bin/bash

GH_ACCESS_TOKEN="$1"
MONGODB_CONNECTION=$(az cosmosdb keys list -n fabrikam-cdb-aes  -g fabrikam-rg-aes --type connection-strings \
--query "connectionStrings[?description=='Primary MongoDB Connection String'].connectionString" | tr -d '\n',' ','[',']','\"' | sed s/\?/contentdb\?/)
SUFFIX="aes"
RESOURCE_GROUP_NAME="fabrikam-rg-"$SUFFIX
WEBAPP_NAME="fabrikam-webapp-"$SUFFIX
docker run -it --rm -e MONGODB_CONNECTION=$MONGODB_CONNECTION ghcr.io/andrewsutliff-insight/fabrikam-init
az webapp config appsettings set -n $WEBAPP_NAME -g $RESOURCE_GROUP_NAME --settings MONGODB_CONNECTION=$MONGODB_CONNECTION WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
#mongodb connection string should be found after running the infra-init script
az webapp config container set \
    --docker-registry-server-password $GH_ACCESS_TOKEN \
    --docker-registry-server-url https://ghcr.io \
    --docker-registry-server-user notapplicable \
    --multicontainer-config-file docker-compose.yml \
    --multicontainer-config-type COMPOSE \
    --name $WEBAPP_NAME \
    --resource-group $RESOURCE_GROUP_NAME 
