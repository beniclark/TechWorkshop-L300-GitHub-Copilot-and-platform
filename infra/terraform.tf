terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }

  # Backend configuration for remote state
  # REQUIRED for production and team environments
  # Steps to enable:
  # 1. Create storage account: az storage account create -n sttfstatezava -g rg-tfstate -l westus3 --sku Standard_LRS
  # 2. Create container: az storage container create -n tfstate --account-name sttfstatezava
  # 3. Uncomment and run: terraform init -migrate-state
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "sttfstatezava"
  #   container_name       = "tfstate"
  #   key                  = "zava-storefront-dev.tfstate"
  #   use_oidc            = true  # For GitHub Actions with Workload Identity
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = false  # Respect module purge_protection setting
      recover_soft_deleted_key_vaults = true   # Automatically recover if exists
    }
  }
  # subscription_id sourced from ARM_SUBSCRIPTION_ID environment variable
}

provider "azapi" {}
