# Quick Start Guide: Deploy with ASE v3

## Prerequisites Checklist
- [ ] Azure CLI installed (`az --version`)
- [ ] Terraform installed (`terraform --version`)
- [ ] Azure subscription with permissions
- [ ] Azure DevOps project (for pipeline)
- [ ] Sufficient quota for ASE v3 in westus3

## Quick Deploy (Azure Developer CLI)

```bash
# 1. Install azd (if not already installed)
# Windows: winget install microsoft.azd
# macOS: brew tap azure/azd && brew install azd
# Linux: curl -fsSL https://aka.ms/install-azd.sh | bash

# 2. Navigate to repository
cd /path/to/TechWorkshop-L300-GitHub-Copilot-and-platform

# 3. Login to Azure
azd auth login

# 4. Initialize (if not already done)
azd init

# 5. Deploy everything
azd up
# This will:
# - Provision infrastructure (2-3 hours for ASE v3)
# - Build Docker image
# - Deploy application
```

## Quick Deploy (Terraform)

```bash
# 1. Navigate to Terraform directory
cd infra/terraform

# 2. Initialize Terraform
terraform init

# 3. Create terraform.tfvars (optional)
cat > terraform.tfvars << EOF
resource_group_name = "rg-myapp-dev-westus3"
acr_name            = "acrmyappdev"
ase_name            = "ase-myapp-dev"
EOF

# 4. Plan deployment
terraform plan

# 5. Apply (this takes 2-3 hours due to ASE v3)
terraform apply

# 6. Get outputs
terraform output

# 7. Build and push Docker image
ACR_NAME=$(terraform output -raw acr_login_server | cut -d'.' -f1)
az acr build --registry $ACR_NAME --image zava-storefront:latest --file ../../Dockerfile ../../src

# 8. Restart app to pull new image
APP_NAME=$(terraform output -raw app_service_name)
RG_NAME=$(terraform output -raw resource_group_name)
az webapp restart --name $APP_NAME --resource-group $RG_NAME
```

## Azure DevOps Pipeline Setup

### 1. Create Pipeline Variables

In Azure DevOps, add these variables:

| Variable | Value | Secret? |
|----------|-------|---------|
| AZURE_SERVICE_CONNECTION | (your service connection name) | No |
| TF_STATE_RESOURCE_GROUP | (state storage RG) | No |
| TF_STATE_STORAGE_ACCOUNT | (state storage account) | No |
| TF_STATE_CONTAINER | tfstate | No |

### 2. Setup Terraform State Storage

```bash
# Create resource group for state
az group create --name tfstate-rg --location westus3

# Create storage account
az storage account create \
  --name tfstatestorage123 \
  --resource-group tfstate-rg \
  --location westus3 \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name tfstatestorage123
```

### 3. Create Pipeline

1. Go to Azure DevOps
2. Pipelines → New Pipeline
3. Select your repository
4. Use existing YAML: `azure-pipelines.yml`
5. Save and run

## Verify Deployment

```bash
# Check resource group
az group show --name rg-zava-dev-westus3

# List resources
az resource list --resource-group rg-zava-dev-westus3 --output table

# Check ASE status
az appservice ase show --name ase-zava-dev --resource-group rg-zava-dev-westus3

# Check App Service
az webapp show --name app-zava-dev --resource-group rg-zava-dev-westus3

# Get App Service URL
az webapp show --name app-zava-dev --resource-group rg-zava-dev-westus3 --query defaultHostName -o tsv

# View logs
az webapp log tail --name app-zava-dev --resource-group rg-zava-dev-westus3
```

## Troubleshooting

### ASE v3 Taking Too Long
- **Expected**: 2-3 hours for initial deployment
- **Check status**: Azure Portal → Resource Group → ASE resource
- **Be patient**: This is normal for ASE v3

### Terraform Init Fails
```bash
# Clear Terraform cache
rm -rf .terraform
rm .terraform.lock.hcl

# Re-initialize
terraform init
```

### ACR Build Fails
```bash
# Login to Azure
az login

# Verify ACR exists
az acr show --name acrzavadev

# Try build again with verbose output
az acr build --registry acrzavadev --image zava-storefront:latest --file ./Dockerfile ./src --verbose
```

### App Service Not Starting
```bash
# Check logs
az webapp log tail --name app-zava-dev --resource-group rg-zava-dev-westus3

# Check application settings
az webapp config appsettings list --name app-zava-dev --resource-group rg-zava-dev-westus3

# Verify image pull permissions
az role assignment list --assignee <app-service-principal-id> --scope <acr-id>
```

### Terraform State Lock
```bash
# If stuck, force unlock (use with caution)
terraform force-unlock <lock-id>
```

## Cleanup

### Using azd
```bash
azd down
```

### Using Terraform
```bash
cd infra/terraform
terraform destroy
# Confirm with: yes
```

### Manual Cleanup
```bash
# Delete resource group (deletes everything)
az group delete --name rg-zava-dev-westus3 --yes
```

## Cost Optimization Tips

1. **For Development**: Consider using regular App Service instead of ASE v3
2. **Use Basic SKUs**: Where possible (ACR, etc.)
3. **Delete when not in use**: ASE v3 costs ~$1000/month
4. **Monitor costs**: Use Azure Cost Management

## Getting Help

- **Terraform Docs**: `terraform.io/docs`
- **Azure CLI Reference**: `docs.microsoft.com/cli/azure/`
- **ASE v3 Docs**: Search "App Service Environment v3"
- **Repository Issues**: Open a GitHub issue

## Important Notes

⚠️ **ASE v3 is expensive** (~$1000/month minimum)
⚠️ **ASE v3 takes 2-3 hours** to deploy initially
⚠️ **Deletion also takes time** (30-60 minutes)
⚠️ **For dev/test**, consider regular App Service

## Next Steps After Deployment

1. Configure custom domain (if needed)
2. Set up SSL certificate
3. Configure monitoring alerts
4. Review Application Insights data
5. Test application functionality
6. Set up CI/CD for application updates

---
For detailed documentation, see: `infra/terraform/README.md`
