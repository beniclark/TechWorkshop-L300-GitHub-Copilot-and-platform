output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "ase_id" {
  description = "ID of the App Service Environment"
  value       = module.ase.ase_id
}

output "ase_dns_suffix" {
  description = "DNS suffix of the App Service Environment"
  value       = module.ase.ase_dns_suffix
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = module.acr.acr_login_server
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = module.acr.acr_id
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = module.app_service.app_service_url
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.app_service.app_service_name
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.app_insights.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.app_insights.connection_string
  sensitive   = true
}

output "foundry_id" {
  description = "ID of the Microsoft Foundry workspace"
  value       = module.foundry.foundry_id
}

output "foundry_endpoint" {
  description = "Endpoint of the Microsoft Foundry workspace"
  value       = module.foundry.foundry_endpoint
}
