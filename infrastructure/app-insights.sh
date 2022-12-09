SUFFIX="aes"
RESOURCE_GROUP_NAME="fabrikam-rg-"$SUFFIX
LOCATION1="eastus"
APP_INSIGHTS="fabrikamai-"$SUFFIX

az extension add --name application-insights
AI=$(az monitor app-insights component create --app $APP_INSIGHTS --location $LOCATION1 --kind web -g $RESOURCE_GROUP_NAME --application-type web --retention-time 120 -o json)

echo $(echo $AI | jq -r '.instrumentationKey')
