#!/bin/bash

GH_ACCESS_TOKEN="$1"
SUFFIX="aes"
RESOURCE_GROUP_NAME="fabrikam-rg-"$SUFFIX
WEBAPP_NAME="fabrikam-webapp-"$SUFFIX
DB_NAME="fabrikam-cdb-"$SUFFIX
MONGODB_CONNECTION=$(az cosmosdb keys list -n $DB_NAME  -g $RESOURCE_GROUP_NAME --type connection-strings \
--query "connectionStrings[?description=='Primary MongoDB Connection String'].connectionString" | tr -d '\n',' ','[',']','\"' | sed s/\?/contentdb\?/)
docker run -it --rm -e MONGODB_CONNECTION=$MONGODB_CONNECTION ghcr.io/andrewsutliff-insight/fabrikam-init
az webapp config appsettings set -n $WEBAPP_NAME -g $RESOURCE_GROUP_NAME --settings MONGODB_CONNECTION=$MONGODB_CONNECTION
#mongodb connection string should be found after running the infra-init script
az webapp config container set \
    --docker-registry-server-password $GH_ACCESS_TOKEN \
    --docker-registry-server-url https://ghcr.io \
    --docker-registry-server-user notapplicable \
    --multicontainer-config-file docker-compose.yml \
    --multicontainer-config-type COMPOSE \
    --name $WEBAPP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --enable-app-service-storage true
