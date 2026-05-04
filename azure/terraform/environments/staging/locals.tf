# =============================================================================
# LOCALS - STAGING ENVIRONMENT
# =============================================================================
# Defina valores locais computados para evitar repetição.
#
# Documentação:
#   - Locals: https://developer.hashicorp.com/terraform/language/values/locals
#
# Boas práticas:
#   - Use locals para calcular nomes de recursos com padrão consistente
#   - Use locals para tags padrão que se repetem em todos os recursos
#   - Prefira locals a repetir expressões complexas em vários lugares
# =============================================================================

# TODO: Defina seus locals

# locals {
#   # Prefixo padrão para nomes de recursos
#   prefix = "${var.project_name}-${var.environment}"
#
#   # Tags padrão aplicadas a todos os recursos
#   common_tags = merge(var.tags, {
#     Project     = var.project_name
#     Environment = var.environment
#     ManagedBy   = "Terraform"
#     CreatedAt   = timestamp()
#   })
#
#   # Convenção de nomes por tipo de recurso (seguindo naming convention Azure)
#   # Referência: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
#   names = {
#     resource_group = "rg-${local.prefix}"
#     vnet           = "vnet-${local.prefix}"
#     aks            = "aks-${local.prefix}"
#     acr            = "acr${replace(local.prefix, "-", "")}"  # ACR não aceita hífens
#     key_vault      = "kv-${local.prefix}"
#     storage        = "st${replace(local.prefix, "-", "")}"   # Storage não aceita hífens
#   }
# }
