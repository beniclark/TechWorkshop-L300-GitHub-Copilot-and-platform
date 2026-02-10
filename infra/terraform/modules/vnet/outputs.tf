output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "ase_subnet_id" {
  description = "ID of the ASE subnet"
  value       = azurerm_subnet.ase_subnet.id
}

output "ase_subnet_name" {
  description = "Name of the ASE subnet"
  value       = azurerm_subnet.ase_subnet.name
}
