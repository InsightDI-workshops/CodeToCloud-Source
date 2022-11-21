#!/bin/bash

SUFFIX="aes"
RESOURCE_GROUP_NAME="fabmedical-rg-"$SUFFIX
DB_NAME="fabmedical-cdb-"$SUFFIX
WEBAPP_NAME="fabmedical-web-"$SUFFIX
PLAN_NAME="fabmedical-plan-"$SUFFIX
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
  
