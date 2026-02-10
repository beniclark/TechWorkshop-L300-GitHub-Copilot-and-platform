variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "zava-dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-zava-dev-westus3"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westus3"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-zava-dev"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "ase_subnet_name" {
  description = "Name of the ASE subnet"
  type        = string
  default     = "snet-ase"
}

variable "ase_subnet_prefix" {
  description = "Address prefix for the ASE subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "ase_name" {
  description = "Name of the App Service Environment"
  type        = string
  default     = "ase-zava-dev"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
  default     = "acrzavadev"
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Basic"
}

variable "app_insights_name" {
  description = "Name of Application Insights"
  type        = string
  default     = "appi-zava-dev"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "asp-zava-dev"
}

variable "app_service_plan_sku" {
  description = "SKU for App Service Plan in ASE v3"
  type        = string
  default     = "I1v2"
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
  default     = "app-zava-dev"
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = "zava-storefront"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "foundry_name" {
  description = "Name of the Microsoft Foundry workspace"
  type        = string
  default     = "foundry-zava-dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "ZavaStorefront"
    ManagedBy   = "Terraform"
  }
}
