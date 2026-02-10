resource "azurerm_service_plan" "plan" {
  name                       = var.app_service_plan_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  os_type                    = "Linux"
  sku_name                   = var.sku_name
  app_service_environment_id = var.ase_id

  tags = var.tags
}
