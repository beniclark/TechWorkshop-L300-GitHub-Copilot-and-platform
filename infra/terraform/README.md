# Terraform Infrastructure for Zava Storefront with ASE v3

This infrastructure deploys the Zava Storefront application to Azure using Terraform, featuring an **App Service Environment v3 (ASE v3)** for secure, isolated hosting.

## Architecture Overview

The infrastructure includes:

- **App Service Environment v3 (ASE v3)**: Fully isolated and dedicated environment for hosting App Service apps
- **Virtual Network**: Dedicated VNet with subnet delegated for ASE v3
- **Azure Container Registry (ACR)**: For storing Docker images
- **Linux App Service Plan**: Hosted in ASE v3 with I1v2 SKU
- **Linux Web App**: Containerized .NET application
- **Application Insights**: For monitoring and telemetry
- **Log Analytics Workspace**: Backend for Application Insights
- **Microsoft Foundry**: Azure AI Foundry workspace for GPT-4 and Phi models
- **RBAC Integration**: Managed identity for secure ACR access

## Prerequisites

Before deploying, ensure you have:

1. **Azure CLI** installed and authenticated: `az login`
2. **Terraform** (>= 1.0) installed
3. **Azure Developer CLI (azd)** installed (optional, for azd workflows)
4. **Azure Subscription** with appropriate permissions
5. **Sufficient quota** for ASE v3 in westus3 region

## Important Notes about ASE v3

⚠️ **ASE v3 Considerations:**

- **Deployment Time**: ASE v3 can take 2-3 hours to provision initially
- **Cost**: ASE v3 is significantly more expensive than regular App Service (~$1000/month base)
- **Isolation**: Provides network isolation and dedicated compute
- **Subnet**: Requires a dedicated subnet with delegation to `Microsoft.Web/hostingEnvironments`
- **Minimum Subnet Size**: /24 (256 addresses) recommended

## Directory Structure

```
infra/terraform/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
└── modules/
    ├── ase/                   # App Service Environment v3
    ├── vnet/                  # Virtual Network and subnets
    ├── acr/                   # Azure Container Registry
    ├── app_service_plan/      # App Service Plan (in ASE)
    ├── app_service/           # Linux Web App
    ├── app_insights/          # Application Insights
    ├── foundry/               # Microsoft Foundry (AI Foundry)
    └── role_assignment/       # RBAC for ACR access
```

## Quick Start

### Option 1: Using Azure Developer CLI (azd)

```bash
# Initialize azd
azd init

# Login to Azure
azd auth login

# Provision infrastructure
azd provision

# Build and deploy application
azd deploy

# Or do everything in one command
azd up
```

### Option 2: Using Terraform Directly

```bash
# Navigate to Terraform directory
cd infra/terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration (takes 2-3 hours due to ASE v3)
terraform apply

# After infrastructure is ready, build and push Docker image
ACR_NAME=$(terraform output -raw acr_login_server | cut -d'.' -f1)
az acr build --registry $ACR_NAME --image zava-storefront:latest --file ../../Dockerfile ../../src

# Restart the app service to pull latest image
APP_NAME=$(terraform output -raw app_service_name)
RG_NAME=$(terraform output -raw resource_group_name)
az webapp restart --name $APP_NAME --resource-group $RG_NAME
```

## Configuration

### Customizing Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
environment_name        = "zava-prod"
resource_group_name     = "rg-zava-prod-westus3"
location                = "westus3"
ase_name                = "ase-zava-prod"
acr_name                = "acrzavaprod"
app_service_name        = "app-zava-prod"
vnet_address_space      = ["10.1.0.0/16"]
ase_subnet_prefix       = "10.1.0.0/24"

tags = {
  Environment = "Production"
  Project     = "ZavaStorefront"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
```

### Available Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment_name` | Environment name | `zava-dev` |
| `resource_group_name` | Resource group name | `rg-zava-dev-westus3` |
| `location` | Azure region | `westus3` |
| `ase_name` | ASE v3 name | `ase-zava-dev` |
| `vnet_address_space` | VNet address space | `["10.0.0.0/16"]` |
| `ase_subnet_prefix` | ASE subnet prefix | `10.0.0.0/24` |
| `acr_name` | ACR name (globally unique) | `acrzavadev` |
| `app_service_plan_sku` | App Service Plan SKU | `I1v2` |

## Azure DevOps Pipeline

The infrastructure includes an Azure DevOps pipeline (`azure-pipelines.yml`) that:

1. **Validates** Terraform configuration
2. **Builds** Docker image using ACR Build (no local Docker needed)
3. **Applies** Terraform changes to infrastructure
4. **Deploys** the application to App Service

### Pipeline Variables Required

Configure these variables in your Azure DevOps pipeline:

- `AZURE_SERVICE_CONNECTION`: Service connection name
- `TF_STATE_RESOURCE_GROUP`: Resource group for Terraform state
- `TF_STATE_STORAGE_ACCOUNT`: Storage account for Terraform state
- `TF_STATE_CONTAINER`: Container name for Terraform state

## Outputs

After deployment, Terraform outputs the following:

```bash
terraform output
```

- `resource_group_name`: Name of the resource group
- `ase_id`: ID of the App Service Environment
- `ase_dns_suffix`: DNS suffix for apps in ASE
- `acr_login_server`: ACR login server URL
- `app_service_url`: URL of the web application
- `app_insights_instrumentation_key`: Application Insights key (sensitive)
- `foundry_endpoint`: Microsoft Foundry endpoint

## Security Features

1. **No Admin Credentials**: ACR has admin account disabled
2. **Managed Identity**: App Service uses system-assigned managed identity
3. **RBAC**: AcrPull role assigned to App Service identity
4. **Network Isolation**: ASE v3 provides network-level isolation
5. **TLS**: TLS 1.0 disabled on ASE
6. **Internal Encryption**: Enabled for ASE v3

## Monitoring

Application Insights is configured automatically:

```bash
# View logs
az monitor app-insights query \
  --app $(terraform output -raw app_insights_name) \
  --analytics-query "requests | limit 50"
```

## Cleanup

To destroy all resources:

```bash
# Using azd
azd down

# Using Terraform
cd infra/terraform
terraform destroy
```

⚠️ Note: ASE v3 deletion also takes time (30-60 minutes).

## Troubleshooting

### ASE v3 Provisioning Takes Too Long

This is expected. ASE v3 can take 2-3 hours for initial deployment.

### ACR Image Pull Failures

Ensure the managed identity role assignment is complete:

```bash
# Check role assignments
az role assignment list \
  --assignee $(terraform output -raw app_service_principal_id) \
  --scope $(terraform output -raw acr_id)
```

### App Service Not Starting

Check logs:

```bash
az webapp log tail \
  --name $(terraform output -raw app_service_name) \
  --resource-group $(terraform output -raw resource_group_name)
```

## Cost Optimization

ASE v3 is expensive. For development:

- Consider using regular App Service instead of ASE v3
- Use Basic SKUs where possible
- Delete resources when not in use

## Support

For issues related to:
- Terraform configuration: Check module documentation
- Azure resources: Consult Azure documentation
- Application: Check Application Insights logs

## Contributing

See the main repository README for contribution guidelines.

## License

See LICENSE file in the repository root.
