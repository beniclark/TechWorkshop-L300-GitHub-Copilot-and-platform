# -----------------------------------------------------------------------------
# App Service Plan
# Linux container hosting for the web application
# -----------------------------------------------------------------------------

module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "~> 0.3"

  name                = local.app_service_plan_name
  resource_group_name = module.resource_group.name
  location            = var.location
  enable_telemetry    = true

  # Linux containers
  os_type  = "Linux"
  sku_name = var.app_service_sku

  # Zone redundancy for prod (requires Premium SKU)
  zone_balancing_enabled = var.environment == "prod" && contains(["P1v3", "P2v3", "P3v3"], var.app_service_sku)

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# -----------------------------------------------------------------------------
# App Service (Web App)
# Container-based deployment pulling from ACR via Managed Identity
# -----------------------------------------------------------------------------

module "app_service" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "~> 0.15"

  name                = local.app_service_name
  resource_group_name = module.resource_group.name
  location            = var.location
  enable_telemetry    = true

  kind                     = "webapp"
  os_type                  = "Linux"
  service_plan_resource_id = module.app_service_plan.resource_id

  # System-Assigned Managed Identity for ACR pull
  managed_identities = {
    system_assigned = true
  }

  # Site configuration
  site_config = {
    always_on              = local.app_service_config.always_on
    use_32_bit_worker      = local.app_service_config.use_32_bit_worker
    ftps_state             = "Disabled"
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = false

    # Container configuration - pull from ACR using docker_image_name format
    application_stack = {
      default = {
        docker_image_name     = "zavastorefront:latest"
        docker_registry_url   = "https://${module.container_registry.resource.login_server}"
      }
    }

    # Health check
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
  }

  # App settings including Application Insights
  # Note: DOCKER_REGISTRY_SERVER_URL is set via application_stack.docker_registry_url, not here
  app_settings = {
    # Application Insights integration
    APPLICATIONINSIGHTS_CONNECTION_STRING      = module.application_insights.resource.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"

    # Container settings (registry URL is set in application_stack)
    DOCKER_ENABLE_CI                    = "true"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"

    # ASP.NET Core settings
    ASPNETCORE_ENVIRONMENT = var.environment == "prod" ? "Production" : "Development"
    DOTNET_VERSION         = local.app_service_config.dotnet_version

    # Disable SCM basic auth (security)
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
  }

  # Diagnostic settings
  diagnostic_settings = {
    to_log_analytics = {
      name                  = "appservice-diagnostics"
      workspace_resource_id = module.log_analytics.resource_id
    }
  }

  # Logging configuration
  logs = {
    default = {
      application_logs = {
        default = {
          file_system_level = var.environment != "prod" ? "Information" : "Error"
        }
      }
      detailed_error_messages = var.environment != "prod"
      failed_request_tracing  = var.environment != "prod"
      http_logs = {
        default = {
          file_system = {
            retention_in_days = 7
            retention_in_mb   = 35
          }
        }
      }
    }
  }

  tags = local.common_tags

  # Lifecycle management
  lifecycle {
    prevent_destroy = false  # Set to true for prod
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name  # Managed by CI/CD
    ]
  }

  depends_on = [
    module.app_service_plan,
    module.container_registry,
    module.application_insights
  ]
}
