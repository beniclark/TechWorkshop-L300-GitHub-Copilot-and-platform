# -----------------------------------------------------------------------------
# Azure AI Foundry (formerly Azure Machine Learning)
# AI Hub + Project for GPT-4 and Phi model support
# -----------------------------------------------------------------------------

# Storage Account for AI Hub (required dependency)
module "ai_storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  count = var.enable_ai_foundry ? 1 : 0

  name                = local.storage_account_name
  resource_group_name = module.resource_group.name
  location            = var.location
  enable_telemetry    = true

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Security settings
  public_network_access_enabled   = var.environment != "prod" # Disable for production
  shared_access_key_enabled       = true                      # Required for AI workspace
  allow_nested_items_to_be_public = false

  # Lifecycle protection
  lifecycle {
    prevent_destroy = false  # Set to true for prod to prevent accidental deletion
  }

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# Key Vault for AI Hub (required dependency)
module "ai_key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10"

  count = var.enable_ai_foundry ? 1 : 0

  name                = local.key_vault_name
  resource_group_name = module.resource_group.name
  location            = var.location
  enable_telemetry    = true
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # SKU
  sku_name = "standard"

  # Security: Purge protection for production only (allows dev resource recreation)
  purge_protection_enabled   = var.environment == "prod"
  soft_delete_retention_days = var.environment == "prod" ? 90 : 7

  # Enable RBAC authorization (default is false for legacy_access_policies_enabled)
  legacy_access_policies_enabled = false

  # Network settings - restrict public access in production
  public_network_access_enabled = var.environment != "prod"

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# Current client configuration for tenant ID
data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Azure AI Hub (Foundry)
# Central hub for AI projects and model deployments
# -----------------------------------------------------------------------------

module "ai_hub" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "~> 0.9"

  count = var.enable_ai_foundry ? 1 : 0

  name                = local.ai_hub_name
  resource_group_name = module.resource_group.name
  location            = var.location
  enable_telemetry    = true

  # AI Hub type
  kind = "Hub"

  # Required dependencies (using object syntax per AVM module)
  storage_account = {
    resource_id = module.ai_storage[0].resource_id
  }

  key_vault = {
    resource_id = module.ai_key_vault[0].resource_id
  }

  # Container registry for custom models
  container_registry = {
    resource_id = module.container_registry.resource_id
  }

  # Application Insights integration
  application_insights = {
    resource_id = module.application_insights.resource_id
  }

  # Managed Identity
  managed_identities = {
    system_assigned = true
  }

  # Network settings - restrict public access in production
  public_network_access_enabled = var.environment != "prod"

  tags = local.common_tags

  depends_on = [
    module.ai_storage,
    module.ai_key_vault,
    module.container_registry,
    module.application_insights
  ]
}

# -----------------------------------------------------------------------------
# Azure AI Project
# Project workspace for ZavaStorefront AI features
# -----------------------------------------------------------------------------

module "ai_project" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "~> 0.9"

  count = var.enable_ai_foundry ? 1 : 0

  name                = local.ai_project_name
  resource_group_name = module.resource_group.name
  location            = var.location
  enable_telemetry    = true

  # AI Project type linked to Hub
  kind = "Project"
  azure_ai_hub = {
    resource_id = module.ai_hub[0].resource_id
  }

  # Inherit dependencies from Hub (using object syntax)
  storage_account = {
    resource_id = module.ai_storage[0].resource_id
  }

  key_vault = {
    resource_id = module.ai_key_vault[0].resource_id
  }

  application_insights = {
    resource_id = module.application_insights.resource_id
  }

  # Managed Identity
  managed_identities = {
    system_assigned = true
  }

  tags = local.common_tags

  depends_on = [module.ai_hub]
}

# -----------------------------------------------------------------------------
# Role Assignment: App Service → AI Project (Cognitive Services User)
# Enables App Service to call AI models
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "app_service_ai_user" {
  count = var.enable_ai_foundry ? 1 : 0

  scope                = module.ai_project[0].resource_id
  role_definition_name = "Azure AI Developer"
  principal_id         = module.app_service.resource.identity[0].principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [module.app_service, module.ai_project]
}
