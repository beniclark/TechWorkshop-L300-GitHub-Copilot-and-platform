# Microsoft Foundry is Azure AI Foundry (formerly Azure AI Studio)
# This creates an AI Hub and associated resources

locals {
  # Storage account name: lowercase, alphanumeric only, 3-24 chars
  storage_name = lower(replace(substr(var.foundry_name, 0, 20), "-", ""))
  # Key Vault name: alphanumeric and hyphens, 3-24 chars
  kv_name = substr(var.foundry_name, 0, 21)
}

resource "azurerm_storage_account" "foundry_storage" {
  name                     = "${local.storage_name}sa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_key_vault" "foundry_kv" {
  name                       = "${local.kv_name}-kv"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = var.tags
}

resource "azurerm_machine_learning_workspace" "foundry_hub" {
  name                    = var.foundry_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.app_insights_id
  key_vault_id            = azurerm_key_vault.foundry_kv.id
  storage_account_id      = azurerm_storage_account.foundry_storage.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

data "azurerm_client_config" "current" {}
