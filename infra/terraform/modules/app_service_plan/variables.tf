variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "ase_id" {
  description = "ID of the App Service Environment"
  type        = string
}

variable "sku_name" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "I1v2"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
