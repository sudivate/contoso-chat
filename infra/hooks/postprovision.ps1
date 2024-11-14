#!/usr/bin/env pwsh
Write-Host "Starting postprovisioning..."

# Retrieve service names, resource group name, and other values from environment variables
$resourceGroupName = $env:AZURE_RESOURCE_GROUP
Write-Host "resourceGroupName: $resourceGroupName"

$openAiService = $env:AZURE_OPENAI_NAME
Write-Host "openAiService: $openAiService"

$subscriptionId = $env:AZURE_SUBSCRIPTION_ID
Write-Host "subscriptionId: $subscriptionId"

$cosmosService = $env:AZURE_COSMOS_NAME
Write-Host "cosmosServiceName: $cosmosService"

$cosmosService = $env:COSMOS_ENDPOINT
Write-Host "cosmosServiceEndpoint: $cosmosService"

$azureSearchEndpoint = $env:AZURE_SEARCH_ENDPOINT
Write-Host "azureSearchEndpoint: $azureSearchEndpoint"

# Ensure all required environment variables are set
if ([string]::IsNullOrEmpty($resourceGroupName) -or [string]::IsNullOrEmpty($openAiService) -or [string]::IsNullOrEmpty($subscriptionId)) {
    Write-Host "One or more required environment variables are not set."
    Write-Host "Ensure that AZURE_RESOURCE_GROUP, AZURE_OPENAI_NAME, AZURE_SUBSCRIPTION_ID are set."
    exit 1
}

# Set additional environment variables expected by app 
# TODO: Standardize these and remove need for setting here
azd env set AZURE_OPENAI_API_VERSION 2023-03-15-preview
azd env set AZURE_OPENAI_CHAT_DEPLOYMENT gpt-4
azd env set AZURE_SEARCH_ENDPOINT $AZURE_SEARCH_ENDPOINT
azd env set AZURE_TRACING_GEN_AI_CONTENT_RECORDING_ENABLED true
azd env set LOCAL_TRACING_ENABLED false
azd env set OTEL_EXPORTER_OTLP_ENDPOINT http://localhost:4317


# Output environment variables to .env file using azd env get-values
azd env get-values > .env
Write-Host "Script execution completed successfully."

Write-Host 'Installing dependencies from "requirements.txt"'
python -m pip install -r ./src/api/requirements.txt > $null

# populate data
Write-Host "Populating data ...."
jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/customer_info/create-cosmos-db.ipynb > $null
jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/product_info/create-azure-search.ipynb > $null


# Write-Output  "Building contosochatweb:latest..."
# Write-Output "Warning: Building Frotend Image take a while, please be patient"
# Write-output "Alternatively you can skip this step and build it manually"
# az acr build --subscription $env:AZURE_SUBSCRIPTION_ID --registry $env:AZURE_CONTAINER_REGISTRY_NAME --image contosochatweb:latest ./src/web/
# $web_image_name = $env:AZURE_CONTAINER_REGISTRY_NAME + '.azurecr.io/contosochatweb:latest'
# az containerapp update --subscription $env:AZURE_SUBSCRIPTION_ID --name $env:WEBAPP_ACA_NAME --resource-group $env:AZURE_RESOURCE_GROUP --image $web_image_name
# az containerapp ingress update --subscription $env:AZURE_SUBSCRIPTION_ID --name $env:WEBAPP_ACA_NAME --resource-group $env:AZURE_RESOURCE_GROUP --target-port 3000