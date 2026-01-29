# ZavaStorefront Infrastructure

This folder contains the Azure infrastructure as code (IaC) using Bicep templates for deploying the ZavaStorefront web application.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Resource Group (rg-zavastore-dev)            │
│                         Region: westus3                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐     AcrPull      ┌──────────────────────┐│
│  │ Azure Container  │◄─────────────────│  Linux App Service   ││
│  │    Registry      │  (Managed ID)    │  (Web App for        ││
│  │    (Basic)       │                  │   Containers)        ││
│  └──────────────────┘                  └──────────┬───────────┘│
│                                                   │             │
│  ┌──────────────────┐                 ┌───────────▼───────────┐│
│  │ App Service Plan │                 │  Application Insights ││
│  │ (Linux, B1)      │                 │                       ││
│  └──────────────────┘                 └───────────┬───────────┘│
│                                                   │             │
│  ┌──────────────────┐                 ┌───────────▼───────────┐│
│  │ Microsoft        │                 │   Log Analytics       ││
│  │ Foundry (AI)     │                 │   Workspace           ││
│  │ GPT-4, GPT-3.5   │                 │                       ││
│  └──────────────────┘                 └───────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Resources Deployed

| Resource | Type | SKU | Purpose |
|----------|------|-----|---------|
| Resource Group | Microsoft.Resources/resourceGroups | N/A | Container for all resources |
| Azure Container Registry | Microsoft.ContainerRegistry/registries | Basic | Store Docker images |
| App Service Plan | Microsoft.Web/serverfarms | B1 (Linux) | Hosting plan for web app |
| App Service | Microsoft.Web/sites | N/A | Web App for Containers |
| Application Insights | Microsoft.Insights/components | N/A | Application monitoring |
| Log Analytics Workspace | Microsoft.OperationalInsights/workspaces | PerGB2018 | Centralized logging |
| Azure OpenAI | Microsoft.CognitiveServices/accounts | S0 | AI models (GPT-4, GPT-3.5) |

## File Structure

```
infra/
├── main.bicep                    # Root orchestration template
├── main.parameters.json          # Parameters file
├── README.md                     # This file
└── modules/
    ├── acr.bicep                # Azure Container Registry
    ├── appServicePlan.bicep     # App Service Plan
    ├── appService.bicep         # Web App for Containers
    ├── appInsights.bicep        # Application Insights
    ├── logAnalytics.bicep       # Log Analytics Workspace
    ├── foundry.bicep            # Azure OpenAI (Microsoft Foundry)
    └── roleAssignment.bicep     # AcrPull role assignment
```

## Prerequisites

- Azure CLI installed
- Azure Developer CLI (azd) installed
- Azure subscription with appropriate permissions
- Logged in to Azure (`az login`)

## Deployment

### Using Azure Developer CLI (AZD)

1. **Initialize the project** (if not already done):
   ```bash
   azd init
   ```

2. **Preview the deployment**:
   ```bash
   azd provision --preview
   ```

3. **Deploy infrastructure and application**:
   ```bash
   azd up
   ```

### Build and Push Container Image

Build the container image using Azure Container Registry (no local Docker required):

```bash
az acr build --registry <acr-name> --image zavastore:latest ./src
```

### Manual Deployment

If you prefer to deploy manually:

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>

# Deploy infrastructure
az deployment sub create \
  --location westus3 \
  --template-file main.bicep \
  --parameters main.parameters.json \
  --parameters environmentName=dev
```

## Configuration

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| environmentName | Environment name (dev, staging, prod) | Required |
| location | Azure region | westus3 |
| containerImageName | Container image name with tag | zavastore:latest |

### Environment Variables

The App Service is configured with the following environment variables:

- `APPLICATIONINSIGHTS_CONNECTION_STRING` - Application Insights connection
- `APPINSIGHTS_INSTRUMENTATIONKEY` - Application Insights key
- `ASPNETCORE_ENVIRONMENT` - Set to Production
- `DOCKER_REGISTRY_SERVER_URL` - ACR login server URL

## Security Features

- **Managed Identity**: System-assigned managed identity for App Service
- **AcrPull Role**: App Service can pull images from ACR without passwords
- **HTTPS Only**: All traffic is encrypted
- **TLS 1.2**: Minimum TLS version enforced
- **FTPS Disabled**: FTP deployments are disabled

## Estimated Costs (Dev Environment)

| Resource | SKU | Estimated Monthly Cost |
|----------|-----|------------------------|
| Container Registry | Basic | ~$5 |
| App Service Plan | B1 | ~$13 |
| Application Insights | Pay-as-you-go | ~$2-5 |
| Log Analytics | Pay-as-you-go | ~$2-5 |
| Azure OpenAI | S0 | Pay-per-token |

**Total estimated**: ~$25-30/month (excluding AI usage)

## Troubleshooting

### Common Issues

1. **ACR Pull Fails**: Ensure the managed identity role assignment is complete
2. **Container Not Starting**: Check container logs in App Service
3. **AI Models Not Available**: Verify model availability in westus3 region

### Useful Commands

```bash
# Check deployment status
az deployment sub show --name <deployment-name>

# View App Service logs
az webapp log tail --name <app-name> --resource-group <rg-name>

# Restart App Service
az webapp restart --name <app-name> --resource-group <rg-name>
```

## Related Links

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
