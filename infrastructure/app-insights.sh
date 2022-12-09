#!/bin/bash

GH_ACCESS_TOKEN="$1"
SUFFIX="aes"
RESOURCE_GROUP_NAME="fabrikam-rg-"$SUFFIX
WEBAPP_NAME="fabrikam-webapp-"$SUFFIX
LOCATION1="eastus"
APP_INSIGHTS="fabrikamai-"$SUFFIX

az extension add --name application-insights
AI=$(az monitor app-insights component create --app $APP_INSIGHTS --location $LOCATION1 --kind web -g $RESOURCE_GROUP_NAME --application-type web --retention-time 120 -o json)
AI_KEY=$(echo $AI | jq -r '.instrumentationKey')
echo $AI_KEY

sed -i '' "s/^appInsights.setup.*/appInsights\.setup(\"${AI_KEY}\");/" ./content-web/app.js

git add .
git commit -m "Added Application Insights"
git push

sleep 250

az webapp config container set \
    --docker-registry-server-password $GH_ACCESS_TOKEN \
    --docker-registry-server-url https://ghcr.io \
    --docker-registry-server-user notapplicable \
    --multicontainer-config-file docker-compose.yml \
    --multicontainer-config-type COMPOSE \
    --name $WEBAPP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --enable-app-service-storage true
