# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod). Used for resource naming and tagging."
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for all resources. westus3 recommended for production."
  default     = "westus3"
  validation {
    condition     = can(regex("^[a-z]+[0-9]*$", var.location))
    error_message = "Location must be a valid Azure region name (e.g., westus3, eastus, westeurope)."
  }
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming. Should be short (max 10 chars)."
  default     = "zava"
  validation {
    condition     = length(var.project_name) <= 10
    error_message = "Project name must be 10 characters or less."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "owner" {
  type        = string
  description = "Owner of the resources for tagging purposes."
  default     = "ZavaStorefront"
}

variable "app_service_sku" {
  type        = string
  description = "SKU for the App Service Plan. B1 recommended for dev, P1v3 for prod."
  default     = "B1"
}

variable "acr_sku" {
  type        = string
  description = "SKU for Azure Container Registry. Basic for dev, Standard/Premium for prod."
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
}

variable "enable_ai_foundry" {
  type        = bool
  description = "Whether to provision Azure AI Foundry resources."
  default     = true
}

variable "ai_models" {
  type = list(object({
    name    = string
    model   = string
    version = string
  }))
  description = "List of AI models to deploy in Azure AI Foundry."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources."
  default     = {}
}
