variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "app_service_plan_id" {
  description = "ID of the App Service Plan"
  type        = string
}

variable "acr_login_server" {
  description = "Login server for Azure Container Registry"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
}

variable "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
