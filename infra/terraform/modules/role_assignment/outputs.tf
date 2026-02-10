output "role_assignment_id" {
  description = "ID of the role assignment"
  value       = azurerm_role_assignment.acr_pull.id
}
