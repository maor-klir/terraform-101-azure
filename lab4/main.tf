
resource "azurerm_resource_group" "main" {
  name     = "rg-terraform-101-${var.application_name}-${var.environment_name}"
  location = var.primary_location
}

resource "random_string" "keyvault-suffix" {
  length  = 6
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                      = "kv-${var.application_name}-${var.environment_name}-${random_string.keyvault-suffix.result}"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "terraform_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_log_analytics_workspace" "observability" {
  name                = "log-observability-dev"
  resource_group_name = "rg-terraform-101-observability-dev"
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = "diag-${var.application_name}-${var.environment_name}-${random_string.keyvault-suffix.result}"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.observability.id

  enabled_log {
    category_group = "audit"
  }
  enabled_log {
    category_group = "allLogs"
  }
  metric {
    category = "AllMetrics"
  }
}
