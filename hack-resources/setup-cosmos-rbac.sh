#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the subscription ID
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using Azure subscription ID: $AZURE_SUBSCRIPTION_ID"

# Get the current user's principal ID.
USER_PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)

az cosmosdb sql role assignment create \
    --account-name cosmos-contoso-q5ezmhyg2mjqw \
    --resource-group rg-contosochat \
    --scope "/" \
    --principal-id $USER_PRINCIPAL_ID \
    --role-definition-id 00000000-0000-0000-0000-000000000001 \
    --subscription $AZURE_SUBSCRIPTION_ID

az cosmosdb sql role assignment create \
    --account-name cosmos-contoso-q5ezmhyg2mjqw \
    --resource-group rg-contosochat \
    --scope "/" \
    --principal-id $USER_PRINCIPAL_ID \
    --role-definition-id 00000000-0000-0000-0000-000000000002 \
    --subscription $AZURE_SUBSCRIPTION_ID