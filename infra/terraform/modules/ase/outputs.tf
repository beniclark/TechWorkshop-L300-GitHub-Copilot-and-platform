output "ase_id" {
  description = "ID of the App Service Environment"
  value       = azurerm_app_service_environment_v3.ase.id
}

output "ase_name" {
  description = "Name of the App Service Environment"
  value       = azurerm_app_service_environment_v3.ase.name
}

output "ase_dns_suffix" {
  description = "DNS suffix of the App Service Environment"
  value       = azurerm_app_service_environment_v3.ase.dns_suffix
}

output "ase_internal_inbound_ip_addresses" {
  description = "Internal inbound IP addresses of the ASE"
  value       = azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
}
