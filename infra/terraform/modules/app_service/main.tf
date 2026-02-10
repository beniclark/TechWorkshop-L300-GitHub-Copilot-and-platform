resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.app_service_plan_id

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${var.acr_login_server}/${var.docker_image_name}:${var.docker_image_tag}"
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.app_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.app_insights_instrumentation_key
    "DOCKER_ENABLE_CI"                           = "true"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
