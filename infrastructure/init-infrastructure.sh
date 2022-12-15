SUFFIX="aes"
RESOURCE_GROUP_NAME="fabrikam-rg-"$SUFFIX
DB_NAME="fabrikam-cdb-"$SUFFIX
WEBAPP_NAME="fabrikam-webapp-"$SUFFIX
PLAN_NAME="fabrikam-plan-"$SUFFIX
APP_INSIGHTS="fabrikamai-"$SUFFIX
LOCATION1="eastus"
LOCATION2="eastus2"


az group create -l $LOCATION1 -n $RESOURCE_GROUP_NAME
az cosmosdb create \
        --name $DB_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --locations regionName=$LOCATION1 failoverPriority=0 isZoneRedundant=False \
        --locations regionName=$LOCATION2 failoverPriority=1 isZoneRedundant=True \
        --enable-multiple-write-locations \
        --kind MongoDB 

az appservice plan create --name $PLAN_NAME --resource-group $RESOURCE_GROUP_NAME --sku S1 --is-linux

az webapp create --resource-group $RESOURCE_GROUP_NAME --plan $PLAN_NAME --name $WEBAPP_NAME -i nginx
  
MONGODB_CONNECTION=$(az cosmosdb keys list -n $DB_NAME  -g $RESOURCE_GROUP_NAME --type connection-strings \
--query "connectionStrings[?description=='Primary MongoDB Connection String'].connectionString" | tr -d '\n',' ','[',']','\"' | sed s/\?/contentdb\?/)
docker run --rm -e MONGODB_CONNECTION=$MONGODB_CONNECTION ghcr.io/andrewsutliff-insight/fabrikam-init

az extension add --name application-insights
AI=$(az monitor app-insights component create --app $APP_INSIGHTS --location $LOCATION1 --kind web -g $RESOURCE_GROUP_NAME --application-type web --retention-time 120 -o json)
AI_KEY=$(echo $AI | jq -r '.instrumentationKey')
AI_CONNECTION=$(echo $AI | jq -r '.connectionString')

sed -i "s/^appInsights.setup.*/appInsights\.setup(\"${AI_KEY}\");/" ./content-web/app.js

echo  "AI_CONNECTION=$AI_CONNECTION" >> $GITHUB_OUTPUT
echo "AI_KEY=$AI_KEY" >> $GITHUB_OUTPUT
echo "MONGODB_CONNECTION=$MONGODB_CONNECTION" >> $GITHUB_OUTPUT
