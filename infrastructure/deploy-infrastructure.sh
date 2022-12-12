MONGODB_CONNECTION=$(az cosmosdb keys list -n $DB_NAME  -g $RESOURCE_GROUP_NAME --type connection-strings \
--query "connectionStrings[?description=='Primary MongoDB Connection String'].connectionString" | tr -d '\n',' ','[',']','\"' | sed s/\?/contentdb\?/)
AI= #need to figure out how to grab the json output of my apinsights
AI_KEY=$(echo $AI | jq -r '.instrumentationKey')
AI_CONNECTION=$(echo $AI | jq -r '.connectionString')

az webapp config appsettings set -n $WEBAPP_NAME -g $RESOURCE_GROUP_NAME \
--settings MONGODB_CONNECTION=$MONGODB_CONNECTION \
    APPINSIGHTS_INSTRUMENTATIONKEY=$AI_KEY \
    APPINSIGHTS_PROFILEFEATURE_VERSION=1.0.0 \
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION=1.0.0 \
    APPLICATIONINSIGHTS_CONNECTION_STRING=$AI_CONNECTION \
    ApplicationInsightsAgent_EXTENSION_VERSION=~2 \
    DiagnosticServices_EXTENSION_VERSION=~3 \
    InstrumentationEngine_EXTENSION_VERSION=disabled \
    SnapshotDebugger_EXTENSION_VERSION=disabled \
    XDT_MicrosoftApplicationInsights_BaseExtensions=disabled \
    XDT_MicrosoftApplicationInsights_Mode=recommended \
    XDT_MicrosoftApplicationInsights_PreemptSdk=disabled

az webapp config container set \
    --docker-registry-server-password $GH_ACCESS_TOKEN \
    --docker-registry-server-url https://ghcr.io \
    --docker-registry-server-user notapplicable \
    --multicontainer-config-file docker-compose.yml \
    --multicontainer-config-type COMPOSE \
    --name $WEBAPP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --enable-app-service-storage true \