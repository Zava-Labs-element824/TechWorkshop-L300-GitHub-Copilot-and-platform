targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'australiaeast'

@description('Name of the resource group')
param resourceGroupName string = ''

@description('Name of the container registry')
param containerRegistryName string = ''

@description('Name of the app service plan')
param appServicePlanName string = ''

@description('Name of the web app')
param webAppName string = ''

@description('Name of the log analytics workspace')
param logAnalyticsName string = ''

@description('Name of the application insights')
param appInsightsName string = ''

@description('Container image name')
param containerImageName string = 'zavastore:latest'

@description('Existing Azure OpenAI endpoint')
param azureOpenAIEndpoint string = 'https://aif-gwp5b2mfyr6ek.openai.azure.com/openai/v1/'

@description('Existing Azure OpenAI deployment name')
param azureOpenAIDeploymentName string = 'gpt-4.1-mini'

@secure()
@description('Azure OpenAI API Key')
param azureOpenAIApiKey string = ''

// Tags that should be applied to all resources
var tags = {
  'azd-env-name': environmentName
  'application': 'zavastore'
  'environment': 'dev'
}

// Generate unique names for resources
var abbrs = {
  resourceGroup: 'rg-'
  containerRegistry: 'cr'
  appServicePlan: 'asp-'
  webApp: 'app-'
  logAnalytics: 'log-'
  appInsights: 'appi-'
  aiServices: 'ai-'
}

var uniqueSuffix = substring(uniqueString(subscription().id, environmentName, location), 0, 6)

var actualResourceGroupName = !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourceGroup}${environmentName}-${location}'
var actualContainerRegistryName = !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistry}${environmentName}${uniqueSuffix}'
var actualAppServicePlanName = !empty(appServicePlanName) ? appServicePlanName : '${abbrs.appServicePlan}${environmentName}-${uniqueSuffix}'
var actualWebAppName = !empty(webAppName) ? webAppName : '${abbrs.webApp}${environmentName}-${uniqueSuffix}'
var actualLogAnalyticsName = !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.logAnalytics}${environmentName}-${uniqueSuffix}'
var actualAppInsightsName = !empty(appInsightsName) ? appInsightsName : '${abbrs.appInsights}${environmentName}-${uniqueSuffix}'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: actualResourceGroupName
  location: location
  tags: tags
}

// Deploy Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    name: actualLogAnalyticsName
    location: location
    tags: tags
  }
}

// Deploy Application Insights
module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights'
  scope: rg
  params: {
    name: actualAppInsightsName
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// Deploy Azure Container Registry
module acr 'modules/acr.bicep' = {
  name: 'acr'
  scope: rg
  params: {
    name: actualContainerRegistryName
    location: location
    tags: tags
  }
}

// Deploy App Service Plan
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  scope: rg
  params: {
    name: actualAppServicePlanName
    location: location
    tags: tags
  }
}

// Deploy Web App for Containers
module webApp 'modules/appService.bicep' = {
  name: 'webApp'
  scope: rg
  params: {
    name: actualWebAppName
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: acr.outputs.name
    containerImageName: containerImageName
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    azureOpenAIEndpoint: azureOpenAIEndpoint
    azureOpenAIDeploymentName: azureOpenAIDeploymentName
    azureOpenAIApiKey: azureOpenAIApiKey
  }
}

// Deploy role assignment for ACR pull
module acrPullRole 'modules/roleAssignment.bicep' = {
  name: 'acrPullRole'
  scope: rg
  params: {
    containerRegistryName: acr.outputs.name
    principalId: webApp.outputs.identityPrincipalId
  }
}

// Note: Using existing Azure OpenAI resource instead of deploying new one
// Endpoint: https://aif-gwp5b2mfyr6ek.openai.azure.com/openai/v1/
// Deployment: gpt-4.1-mini

// Outputs
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_APP_SERVICE_NAME string = webApp.outputs.name
output AZURE_APP_SERVICE_URL string = webApp.outputs.url
output AZURE_APP_INSIGHTS_NAME string = appInsights.outputs.name
output AZURE_LOG_ANALYTICS_NAME string = logAnalytics.outputs.name
output AZURE_OPENAI_ENDPOINT string = azureOpenAIEndpoint
output AZURE_OPENAI_DEPLOYMENT_NAME string = azureOpenAIDeploymentName
