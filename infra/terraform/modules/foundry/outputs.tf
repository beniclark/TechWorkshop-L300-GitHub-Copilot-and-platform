output "foundry_id" {
  description = "ID of the Microsoft Foundry workspace"
  value       = azurerm_machine_learning_workspace.foundry_hub.id
}

output "foundry_name" {
  description = "Name of the Microsoft Foundry workspace"
  value       = azurerm_machine_learning_workspace.foundry_hub.name
}

output "foundry_endpoint" {
  description = "Discovery URL of the Microsoft Foundry workspace"
  value       = azurerm_machine_learning_workspace.foundry_hub.discovery_url
}
