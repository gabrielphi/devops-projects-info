# =============================================================================
# MODULE: SECURITY
# =============================================================================
# Módulo responsável por recursos de segurança no Azure.
#
# Recursos que este módulo pode criar:
#   - Azure Key Vault (secrets, keys, certificates)
#   - User-Assigned Managed Identity
#   - Role Assignments (RBAC)
#   - Microsoft Defender for Cloud plans
#   - Log Analytics Workspace (para centralizar logs de segurança)
#   - Diagnostic Settings
#
# Documentação dos recursos:
#   - Key Vault:          https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
#   - Managed Identity:   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
#   - Role Assignment:    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
#   - Log Analytics:      https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
#
# Conceitos de Segurança Azure para estudo:
#   - Managed Identities: https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview
#   - Azure RBAC:         https://learn.microsoft.com/en-us/azure/role-based-access-control/overview
#   - Key Vault best practices: https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices
#   - Microsoft Defender for Cloud: https://learn.microsoft.com/en-us/azure/defender-for-cloud/
# =============================================================================

# Data source para obter o tenant e object ID do current user/service principal
# data "azurerm_client_config" "current" {}

# TODO: Key Vault
# resource "azurerm_key_vault" "main" {
#   name                       = "kv-${var.prefix}"
#   resource_group_name        = var.resource_group_name
#   location                   = var.location
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   sku_name                   = "standard"
#   soft_delete_retention_days = 7
#   purge_protection_enabled   = true  # Obrigatório para produção
#
#   # RBAC ao invés de Access Policies (recomendado)
#   enable_rbac_authorization = true
#
#   network_acls {
#     default_action = "Deny"
#     bypass         = "AzureServices"
#     # ip_rules = ["<seu-ip-publico>"]  # Libere apenas IPs necessários
#   }
#
#   tags = var.tags
# }

# TODO: Dar acesso ao Service Principal/usuário Terraform ao Key Vault
# resource "azurerm_role_assignment" "kv_terraform_admin" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# TODO: User-Assigned Managed Identity (para aplicações que precisam acessar o Key Vault)
# resource "azurerm_user_assigned_identity" "app" {
#   name                = "id-${var.prefix}-app"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   tags                = var.tags
# }

# TODO: Dar permissão de leitura de secrets à identidade da aplicação
# resource "azurerm_role_assignment" "kv_secrets_user" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_user_assigned_identity.app.principal_id
# }

# TODO: Log Analytics Workspace para centralizar logs
# resource "azurerm_log_analytics_workspace" "main" {
#   name                = "log-${var.prefix}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
#   tags                = var.tags
# }
