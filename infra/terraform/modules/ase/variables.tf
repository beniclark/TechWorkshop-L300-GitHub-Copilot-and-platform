variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "ase_name" {
  description = "Name of the App Service Environment"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for ASE"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
