# =============================================================================
# MAIN - PROD ENVIRONMENT
# =============================================================================
# Arquivo principal do ambiente de desenvolvimento.
# Chama os módulos reutilizáveis definidos em ../../modules/.
#
# Documentação:
#   - Modules: https://developer.hashicorp.com/terraform/language/modules
#   - Resource Group: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
#
# Boas práticas:
#   - main.tf deve apenas ORQUESTRAR módulos — sem recursos diretos aqui
#   - Para recursos simples que não justificam módulo, crie arquivos separados (network.tf, etc.)
#   - Prefira for_each ao invés de count para recursos com identidade própria
#   - Use data sources para referenciar recursos existentes (não gerenciados pelo Terraform)
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Group Principal
# -----------------------------------------------------------------------------

# TODO: Crie o Resource Group principal
# resource "azurerm_resource_group" "main" {
#   name     = local.names.resource_group
#   location = var.location
#   tags     = local.common_tags
# }

# -----------------------------------------------------------------------------
# Módulo de Rede
# -----------------------------------------------------------------------------

# TODO: Chame o módulo de networking
# module "networking" {
#   source = "../../modules/networking"
#
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   prefix              = local.prefix
#   vnet_address_space  = var.vnet_address_space
#   subnets             = var.subnets
#   tags                = local.common_tags
# }

# -----------------------------------------------------------------------------
# Módulo de Segurança (Key Vault, NSG, etc.)
# -----------------------------------------------------------------------------

# TODO: Chame o módulo de segurança
# module "security" {
#   source = "../../modules/security"
#
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   prefix              = local.prefix
#   tags                = local.common_tags
# }

# -----------------------------------------------------------------------------
# Módulo de Compute (VMs, VMSS, AKS)
# -----------------------------------------------------------------------------

# TODO: Chame o módulo de compute
# module "compute" {
#   source = "../../modules/compute"
#
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   prefix              = local.prefix
#   subnet_id           = module.networking.subnet_ids["compute"]
#   tags                = local.common_tags
# }

# -----------------------------------------------------------------------------
# Módulo de Database
# -----------------------------------------------------------------------------

# TODO: Chame o módulo de database
# module "database" {
#   source = "../../modules/database"
#
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   prefix              = local.prefix
#   subnet_id           = module.networking.subnet_ids["database"]
#   admin_username      = var.db_admin_username
#   admin_password      = var.db_admin_password
#   tags                = local.common_tags
# }

# -----------------------------------------------------------------------------
# Módulo de Storage
# -----------------------------------------------------------------------------

# TODO: Chame o módulo de storage
# module "storage" {
#   source = "../../modules/storage"
#
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   prefix              = local.prefix
#   tags                = local.common_tags
# }
