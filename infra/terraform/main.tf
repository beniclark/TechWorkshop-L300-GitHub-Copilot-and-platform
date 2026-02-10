terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network for ASE v3
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  ase_subnet_name     = var.ase_subnet_name
  ase_subnet_prefix   = var.ase_subnet_prefix
  tags                = var.tags
}

# App Service Environment v3
module "ase" {
  source              = "./modules/ase"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ase_name            = var.ase_name
  subnet_id           = module.vnet.ase_subnet_id
  tags                = var.tags
}

# Azure Container Registry
module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  acr_name            = var.acr_name
  sku                 = var.acr_sku
  tags                = var.tags
}

# Log Analytics Workspace for Application Insights
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.environment_name}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Application Insights
module "app_insights" {
  source              = "./modules/app_insights"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  app_insights_name   = var.app_insights_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  tags                = var.tags
}

# App Service Plan in ASE v3
module "app_service_plan" {
  source                = "./modules/app_service_plan"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  app_service_plan_name = var.app_service_plan_name
  ase_id                = module.ase.ase_id
  sku_name              = var.app_service_plan_sku
  tags                  = var.tags
  depends_on            = [module.ase]
}

# App Service
module "app_service" {
  source                           = "./modules/app_service"
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  app_service_name                 = var.app_service_name
  app_service_plan_id              = module.app_service_plan.app_service_plan_id
  acr_login_server                 = module.acr.acr_login_server
  app_insights_connection_string   = module.app_insights.connection_string
  app_insights_instrumentation_key = module.app_insights.instrumentation_key
  docker_image_name                = var.docker_image_name
  docker_image_tag                 = var.docker_image_tag
  tags                             = var.tags
}

# Role Assignment - Grant App Service pull access to ACR
module "role_assignment" {
  source       = "./modules/role_assignment"
  principal_id = module.app_service.principal_id
  acr_id       = module.acr.acr_id
}

# Microsoft Foundry (Azure AI Foundry)
module "foundry" {
  source              = "./modules/foundry"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  foundry_name        = var.foundry_name
  app_insights_id     = module.app_insights.app_insights_id
  tags                = var.tags
}
