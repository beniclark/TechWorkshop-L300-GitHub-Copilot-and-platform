output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.plan.id
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.plan.name
}
