# Deployment Checklist for ASE v3 Infrastructure

Use this checklist to ensure a smooth deployment of the Zava Storefront infrastructure with ASE v3.

## Pre-Deployment Checklist

### Azure Subscription Verification
- [ ] Azure subscription is active
- [ ] You have Contributor or Owner role on the subscription
- [ ] Subscription has sufficient quota for ASE v3 in westus3
- [ ] Subscription allows creating resources in westus3

### Tool Installation
- [ ] Azure CLI installed: `az --version`
- [ ] Terraform installed (v1.0+): `terraform --version`
- [ ] Azure Developer CLI installed (optional): `azd version`
- [ ] Git configured: `git --version`

### Authentication
- [ ] Logged into Azure CLI: `az login`
- [ ] Correct subscription selected: `az account show`
- [ ] Can create resources: `az group create --name test-rg --location westus3` (then delete)

### Repository Setup
- [ ] Repository cloned locally
- [ ] On correct branch: `git branch`
- [ ] All files present: `ls azure-pipelines.yml azure.yaml infra/terraform/`

## Configuration Checklist

### Terraform Configuration
- [ ] Reviewed `infra/terraform/variables.tf`
- [ ] Created `infra/terraform/terraform.tfvars` (if customizing)
- [ ] ACR name is globally unique (alphanumeric only)
- [ ] Resource names follow Azure naming conventions
- [ ] Region supports all required services (westus3 recommended)

### Example terraform.tfvars (optional):
```hcl
resource_group_name = "rg-myapp-prod-westus3"
acr_name            = "acrmyappprod"
ase_name            = "ase-myapp-prod"
environment_name    = "myapp-prod"
```

### Backend Configuration (for Terraform state)
- [ ] Remote state storage account created
- [ ] Container created in storage account
- [ ] Service principal has access to state storage
- [ ] Backend configuration added to `main.tf` or provided via CLI

## Deployment Checklist

### Step 1: Initialize
- [ ] Navigate to terraform directory: `cd infra/terraform`
- [ ] Initialize Terraform: `terraform init`
- [ ] Initialization successful (no errors)

### Step 2: Validate
- [ ] Format code: `terraform fmt -recursive`
- [ ] Validate configuration: `terraform validate`
- [ ] Validation successful

### Step 3: Plan
- [ ] Run plan: `terraform plan -out=tfplan`
- [ ] Review planned resources (should create ~15+ resources)
- [ ] Verify resource names
- [ ] Verify locations (westus3)
- [ ] No unexpected deletions

### Step 4: Deploy Infrastructure
- [ ] Apply plan: `terraform apply tfplan` or `terraform apply`
- [ ] Confirm with "yes"
- [ ] **Wait 2-3 hours for ASE v3 deployment** ☕☕☕
- [ ] Check progress in Azure Portal
- [ ] All resources created successfully
- [ ] No errors in output

### Step 5: Verify Infrastructure
- [ ] Get outputs: `terraform output`
- [ ] Resource group exists in Azure Portal
- [ ] ASE v3 is running
- [ ] ACR is accessible
- [ ] App Service Plan is in ASE
- [ ] App Service is created

## Application Deployment Checklist

### Build and Push Docker Image
- [ ] Navigate to repository root
- [ ] Get ACR name: `ACR_NAME=$(cd infra/terraform && terraform output -raw acr_login_server | cut -d'.' -f1)`
- [ ] Build image: `az acr build --registry $ACR_NAME --image zava-storefront:latest --file ./Dockerfile ./src`
- [ ] Build successful
- [ ] Image pushed to ACR
- [ ] Verify image: `az acr repository show --name $ACR_NAME --repository zava-storefront`

### Deploy to App Service
- [ ] Get App Service name: `APP_NAME=$(cd infra/terraform && terraform output -raw app_service_name)`
- [ ] Get Resource Group: `RG_NAME=$(cd infra/terraform && terraform output -raw resource_group_name)`
- [ ] Restart App Service: `az webapp restart --name $APP_NAME --resource-group $RG_NAME`
- [ ] Wait for restart (1-2 minutes)
- [ ] App Service is running

## Post-Deployment Verification

### Infrastructure Verification
- [ ] Access Azure Portal
- [ ] Navigate to resource group
- [ ] Verify all resources:
  - [ ] Virtual Network
  - [ ] ASE v3
  - [ ] App Service Plan
  - [ ] App Service
  - [ ] ACR
  - [ ] Application Insights
  - [ ] Log Analytics Workspace
  - [ ] Key Vault (for Foundry)
  - [ ] Storage Account (for Foundry)
  - [ ] Machine Learning Workspace (Foundry)

### Application Verification
- [ ] Get app URL: `az webapp show --name $APP_NAME --resource-group $RG_NAME --query defaultHostName -o tsv`
- [ ] Access application URL in browser
- [ ] Application loads successfully
- [ ] No error messages
- [ ] Check application logs: `az webapp log tail --name $APP_NAME --resource-group $RG_NAME`

### Monitoring Verification
- [ ] Access Application Insights in Azure Portal
- [ ] See telemetry data arriving
- [ ] View application map
- [ ] Check performance metrics
- [ ] Review any errors or warnings

### Security Verification
- [ ] ACR admin account is disabled
- [ ] App Service uses managed identity
- [ ] Role assignment exists: App Service → ACR (AcrPull)
- [ ] No passwords in configuration
- [ ] TLS 1.0 is disabled on ASE

## Azure DevOps Pipeline Setup (Optional)

### Pipeline Configuration
- [ ] Azure DevOps project created
- [ ] Service connection configured
- [ ] Pipeline variables set:
  - [ ] AZURE_SERVICE_CONNECTION
  - [ ] TF_STATE_RESOURCE_GROUP
  - [ ] TF_STATE_STORAGE_ACCOUNT
  - [ ] TF_STATE_CONTAINER
- [ ] Pipeline YAML file: `azure-pipelines.yml`
- [ ] Pipeline created in Azure DevOps

### Pipeline Execution
- [ ] Push to main branch or trigger manually
- [ ] Pipeline runs without errors
- [ ] Validation stage passes
- [ ] Build stage completes
- [ ] Apply stage succeeds
- [ ] Deploy stage finishes

## Cost Management Checklist

### Review Costs
- [ ] Access Azure Cost Management
- [ ] Review current costs
- [ ] Set up budget alerts
- [ ] Understand ASE v3 costs (~$1000/month)
- [ ] Review other resource costs

### Cost Optimization (if needed)
- [ ] Consider using regular App Service (not ASE v3) for dev/test
- [ ] Use Basic SKUs where appropriate
- [ ] Delete unused resources
- [ ] Schedule shutdown for non-production environments

## Troubleshooting Checklist

If something goes wrong:

### Terraform Issues
- [ ] Check Terraform version compatibility
- [ ] Review error messages carefully
- [ ] Verify Azure permissions
- [ ] Check resource quotas
- [ ] Review Terraform state: `terraform show`

### ASE v3 Issues
- [ ] Check ASE status in Portal
- [ ] Verify subnet configuration
- [ ] Check NSG rules (if any)
- [ ] Review ASE logs
- [ ] Wait longer (it's slow!)

### Application Issues
- [ ] Check App Service logs
- [ ] Verify Docker image exists in ACR
- [ ] Check managed identity permissions
- [ ] Review Application Settings
- [ ] Test image pull: `az acr repository show`

### Pipeline Issues
- [ ] Review pipeline logs
- [ ] Check service connection
- [ ] Verify permissions
- [ ] Review agent logs
- [ ] Test stages individually

## Cleanup Checklist (When Done)

### Using Terraform
- [ ] Navigate to terraform directory: `cd infra/terraform`
- [ ] Destroy resources: `terraform destroy`
- [ ] Confirm with "yes"
- [ ] Wait 30-60 minutes for ASE deletion
- [ ] Verify all resources deleted in Portal

### Manual Cleanup
- [ ] Delete resource group: `az group delete --name rg-zava-dev-westus3 --yes`
- [ ] Delete Terraform state (if using remote state)
- [ ] Remove local Terraform files: `.terraform/`, `*.tfstate*`

### Cost Verification
- [ ] Check Azure Cost Management
- [ ] Verify no ongoing charges
- [ ] Review final costs

## Documentation Checklist

### Save Important Information
- [ ] Note resource names used
- [ ] Save configuration files
- [ ] Document any customizations
- [ ] Save outputs: `terraform output > outputs.txt`
- [ ] Screenshot of working application
- [ ] Note any issues encountered

### Share with Team
- [ ] Update team documentation
- [ ] Share access details (if needed)
- [ ] Document deployment process
- [ ] Note lessons learned

---

## Time Expectations

- **Terraform Init**: 1-2 minutes
- **Terraform Plan**: 1-2 minutes
- **Terraform Apply**: 2-3 hours (mostly ASE v3)
- **Docker Build**: 5-10 minutes
- **App Service Restart**: 1-2 minutes
- **Total First Deployment**: ~3 hours
- **Subsequent Deployments**: 10-20 minutes

## Success Criteria

Deployment is successful when:
- ✅ All Terraform resources created
- ✅ ASE v3 is running
- ✅ Application accessible via URL
- ✅ Application Insights showing data
- ✅ No errors in logs
- ✅ Docker image pulls work
- ✅ All security checks pass

---

**Need Help?** 
- Check `QUICKSTART.md` for commands
- Review `infra/terraform/README.md` for details
- See `IMPLEMENTATION_SUMMARY.md` for overview
- Open a GitHub issue for problems
