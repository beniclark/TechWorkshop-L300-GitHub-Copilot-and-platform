resource "azurerm_app_service_environment_v3" "ase" {
  name                = var.ase_name
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  internal_load_balancing_mode = "Web, Publishing"

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }

  tags = var.tags
}
