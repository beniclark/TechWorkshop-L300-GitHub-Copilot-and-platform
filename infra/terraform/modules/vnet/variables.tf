variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
}

variable "ase_subnet_name" {
  description = "Name of the ASE subnet"
  type        = string
}

variable "ase_subnet_prefix" {
  description = "Address prefix for the ASE subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
