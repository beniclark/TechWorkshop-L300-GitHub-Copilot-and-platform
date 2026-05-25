# ZavaStorefront Infrastructure

This directory contains Terraform configurations for deploying the ZavaStorefront application to Azure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) >= 2.50.0
- Azure subscription with appropriate permissions
- Set `ARM_SUBSCRIPTION_ID` environment variable

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Resource Group (westus3)                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐    RBAC (AcrPull)    ┌──────────────────────┐        │
│  │ App Service  │◄────────────────────►│ Container Registry   │        │
│  │   (Linux)    │                      │      (Basic)         │        │
│  └──────┬───────┘                      └──────────────────────┘        │
│         │                                                               │
│         │ Telemetry                                                     │
│         ▼                                                               │
│  ┌──────────────┐         ┌──────────────────────┐                     │
│  │  Application │◄───────►│   Log Analytics      │                     │
│  │   Insights   │         │     Workspace        │                     │
│  └──────────────┘         └──────────────────────┘                     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     Azure AI Foundry                             │   │
│  │  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐        │   │
│  │  │  AI Hub     │────►│  AI Project │     │  Key Vault  │        │   │
│  │  └─────────────┘     └─────────────┘     └─────────────┘        │   │
│  │                                           ┌─────────────┐        │   │
│  │                                           │   Storage   │        │   │
│  │                                           └─────────────┘        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Quick Start

### ⚠️ FIRST TIME SETUP - State Management

**CRITICAL**: Before running Terraform, ensure state files are secured:

```bash
# 1. Verify state files are NOT in git
git ls-files | grep tfstate  # Should return nothing

# 2. If state files exist, remove from git
git rm --cached terraform.tfstate terraform.tfstate.backup
git commit -m "Remove sensitive state files from version control"
```

### Local Development Workflow

```bash
# 1. Login to Azure
az login

# 2. Set subscription (required)
export ARM_SUBSCRIPTION_ID="your-subscription-id"
# PowerShell: $env:ARM_SUBSCRIPTION_ID = "your-subscription-id"
# PowerShell: $env:ARM_SUBSCRIPTION_ID = "your-subscription-id"

# 3. Initialize Terraform
cd infra
terraform init

# 4. Validate configuration
terraform fmt -check
terraform validate

# 5. Security scan (recommended)
tfsec . --minimum-severity HIGH
# Or: checkov -d . --framework terraform

# 6. Plan deployment
terraform plan -var-file="main.tfvars.json" -out=tfplan

# 7. Review plan carefully before applying
terraform show tfplan

# 8. Apply (after approval)
terraform apply tfplan

# 9. Save outputs for deployment
terraform output -json > outputs.json
```

### Remote State Backend (Recommended for Teams)

For team environments or CI/CD, enable remote state:

```bash
# 1. Create state storage (one-time setup)
az group create --name rg-tfstate --location westus3
az storage account create \
  --name sttfstatezava \
  --resource-group rg-tfstate \
  --location westus3 \
  --sku Standard_LRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name sttfstatezava

# 2. Uncomment backend block in terraform.tf

# 3. Migrate existing state
terraform init -migrate-state

# 4. Verify remote state
az storage blob list \
  --container-name tfstate \
  --account-name sttfstatezava --output table
```

## Deployment Validation

```bash
# Check App Service health
curl https://$(terraform output -raw app_service_url)/health

# View logs
az webapp log tail --name $(terraform output -raw app_service_name) \
  --resource-group $(terraform output -raw resource_group_name)

# Push container image to ACR
az acr login --name $(terraform output -raw acr_name)
docker tag zavastorefront:latest $(terraform output -raw acr_login_server)/zavastorefront:latest
docker push $(terraform output -raw acr_login_server)/zavastorefront:latest
```

## Rollback Strategy

```bash
# Option 1: Revert code and reapply
git revert <commit-hash>
terraform plan -var-file="main.tfvars.json"
terraform apply

# Option 2: Targeted resource recreation
terraform taint module.app_service
terraform apply -var-file="main.tfvars.json"

# Option 3: Import existing resource (if manually changed)
terraform import module.app_service.azurerm_linux_web_app.main /subscriptions/.../resourceGroups/.../providers/Microsoft.Web/sites/...

# Option 4: Destroy specific resource
terraform destroy -target=module.app_service -var-file="main.tfvars.json"
```

## Environment-Specific Settings

| Configuration | Dev | Prod |
|---------------|-----|------|
| App Service SKU | B1 | P1v3 |
| ACR SKU | Basic | Premium |
| ACR Admin | Enabled | Disabled (RBAC only) |
| Public Access | Enabled | Disabled |
| Key Vault Purge | 7 days | 90 days |
| Log Retention | 30 days | 90 days |
| Always On | Disabled | Enabled |

## Troubleshooting

### State Lock Issues
```bash
# Force unlock (use carefully)
terraform force-unlock <lock-id>
```

### ACR Access Denied
```bash
# Verify RBAC assignment
az role assignment list --assignee <app-service-principal-id> --scope <acr-id>

# Use admin credentials temporarily (dev only)
az acr credential show --name <acr-name>
```

### Key Vault Already Exists
```bash
# Recover soft-deleted vault
az keyvault recover --name <vault-name>

# Or purge (wait period required)
az keyvault purge --name <vault-name>
```
```

## Files

| File | Purpose |
|------|---------|
| `terraform.tf` | Provider configuration and version constraints |
| `variables.tf` | Input variable definitions |
| `locals.tf` | Naming conventions and computed values |
| `main.tf` | Resource group |
| `main.acr.tf` | Container Registry with RBAC |
| `main.appservice.tf` | App Service Plan and Web App |
| `main.monitoring.tf` | Log Analytics and Application Insights |
| `main.ai.tf` | Azure AI Foundry (Hub, Project, dependencies) |
| `outputs.tf` | Output values (marked sensitive where appropriate) |
| `main.tfvars.json` | Default configuration values |

## Recent Security Improvements ✅

**State Management**:
- ✅ Added comprehensive .gitignore for state files
- ✅ Documented remote backend setup with OIDC support
- ✅ Added state migration instructions

**Environment-Aware Security**:
- ✅ ACR admin enabled only for dev (disabled in prod)
- ✅ Key Vault purge protection: prod=90 days, dev=7 days
- ✅ Public network access restricted in production
- ✅ Storage account public access controlled by environment

**Resource Protection**:
- ✅ Lifecycle rules added to prevent accidental destruction
- ✅ App Service ignore_changes for CI/CD-managed properties
- ✅ Provider Key Vault settings aligned with module configuration

**Validation & Compliance**:
- ✅ Relaxed location validation for multi-region support
- ✅ Enhanced validation commands in workflow
- ✅ Security scanning integration (tfsec/checkov)

## Security Features

- **No credentials in code**: ACR access via Managed Identity + RBAC
- **State file exclusion**: terraform.tfstate in .gitignore (contains secrets)
- **TLS 1.2 minimum**: Enforced on App Service
- **FTPS disabled**: Secure deployments only
- **Key Vault purge protection**: Environment-aware (prod only)
- **Public access control**: Restricted in production
- **Diagnostic logging**: All resources to Log Analytics
- **Admin credentials**: ACR admin enabled only for dev (initial setup)

## AZD Integration

This infrastructure is designed for Azure Developer CLI (azd):

```bash
# From repository root
azd up          # Provision + deploy
azd down        # Teardown
azd monitor     # Open App Insights
```

See `azure.yaml` in the repository root for AZD configuration.

## Outputs

After deployment, key outputs include:
- `app_service_url` - Application URL
- `acr_login_server` - Container registry for image pushes
- `azure_portal_resource_group_url` - Direct Azure Portal link

## Cost Optimization (Dev)

- App Service: B1 tier (~$13/month)
- ACR: Basic tier (~$5/month)
- Log Analytics: Pay-per-GB
- AI Foundry: Pay-per-use for model inference

For production, upgrade to P1v3 App Service and Standard/Premium ACR.
