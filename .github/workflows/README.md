# GitHub Actions Deployment Setup

Configure the following secrets and variables in your GitHub repository settings.

## Secrets

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Service principal JSON for Azure login. Generate with: `az ad sp create-for-rbac --name "github-actions" --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} --sdk-auth` |
| `ACR_USERNAME` | Azure Container Registry username. Get from: `az acr credential show --name {acr-name} --query username -o tsv` |
| `ACR_PASSWORD` | Azure Container Registry password. Get from: `az acr credential show --name {acr-name} --query "passwords[0].value" -o tsv` |

> **Note:** Enable admin user on ACR first: `az acr update -n {acr-name} --admin-enabled true`

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AZURE_WEBAPP_NAME` | Name of your Azure Web App | `app-myenv-abc123` |
| `ACR_LOGIN_SERVER` | ACR login server URL | `crmyenvabc123.azurecr.io` |

## Finding Your Resource Names

After deploying infrastructure, get values with:

```bash
# Get Web App name
az webapp list --resource-group {resource-group} --query "[0].name" -o tsv

# Get ACR login server
az acr list --resource-group {resource-group} --query "[0].loginServer" -o tsv
```
