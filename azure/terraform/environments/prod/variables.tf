# =============================================================================
# VARIABLES - PROD ENVIRONMENT
# =============================================================================
# Defina todas as variáveis de entrada deste ambiente.
#
# Documentação:
#   - Variables: https://developer.hashicorp.com/terraform/language/values/variables
#   - Validation blocks: https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules
#
# Boas práticas:
#   - Sempre inclua description e type em cada variável
#   - Use validation blocks para capturar erros de configuração cedo
#   - Marque variáveis sensíveis com sensitive = true
#   - Use default apenas quando fizer sentido (não force defaults que mascarem erros)
#   - Defina valores no terraform.tfvars (nunca comitar, use .example)
# =============================================================================

# -----------------------------------------------------------------------------
# Variáveis Globais
# -----------------------------------------------------------------------------

# TODO: Defina variáveis globais
# variable "project_name" {
#   description = "Nome do projeto. Usado como prefixo em todos os recursos."
#   type        = string
#   validation {
#     condition     = length(var.project_name) <= 12 && can(regex("^[a-z0-9-]+$", var.project_name))
#     error_message = "O nome do projeto deve ter no máximo 12 caracteres e conter apenas letras minúsculas, números e hífens."
#   }
# }

# variable "environment" {
#   description = "Nome do ambiente (dev, staging, prod)."
#   type        = string
#   validation {
#     condition     = contains(["dev", "staging", "prod"], var.environment)
#     error_message = "O ambiente deve ser 'dev', 'staging' ou 'prod'."
#   }
# }

# variable "location" {
#   description = "Azure region onde os recursos serão criados."
#   type        = string
#   default     = "eastus"
# }

# variable "tags" {
#   description = "Tags padrão aplicadas a todos os recursos."
#   type        = map(string)
#   default     = {}
# }

# -----------------------------------------------------------------------------
# Variáveis de Rede (Networking)
# -----------------------------------------------------------------------------

# TODO: Defina variáveis de rede
# variable "vnet_address_space" {
#   description = "CIDR block da Virtual Network."
#   type        = list(string)
#   default     = ["10.0.0.0/16"]
# }

# variable "subnets" {
#   description = "Mapa de subnets a serem criadas dentro da VNet."
#   type = map(object({
#     address_prefixes = list(string)
#   }))
# }

# -----------------------------------------------------------------------------
# Variáveis de Compute
# -----------------------------------------------------------------------------

# TODO: Defina variáveis de compute
# variable "vm_size" {
#   description = "Tamanho da VM (SKU do Azure)."
#   type        = string
#   default     = "Standard_B2s"
# }

# -----------------------------------------------------------------------------
# Variáveis de Database
# -----------------------------------------------------------------------------

# TODO: Defina variáveis de banco de dados
# variable "db_admin_username" {
#   description = "Usuário administrador do banco de dados."
#   type        = string
#   sensitive   = true
# }

# variable "db_admin_password" {
#   description = "Senha do administrador do banco de dados. Armazene no Key Vault."
#   type        = string
#   sensitive   = true
# }
