# =============================================================================
# PROVIDERS - STAGING ENVIRONMENT
# =============================================================================
# Configure os providers necessários para o ambiente de desenvolvimento.
#
# Documentação:
#   - AzureRM Provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
#   - AzureAD Provider: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs
#
# Boas práticas:
#   - Sempre pin a versão do provider com ~> (ex: ~> 3.0 permite 3.x mas não 4.0)
#   - Defina features {} mesmo que vazio (obrigatório no azurerm)
#   - Use variáveis de ambiente para autenticação (ARM_CLIENT_ID, ARM_CLIENT_SECRET, etc.)
#   - Nunca hardcode credenciais aqui
#
# Autenticação via Service Principal (recomendado para CI/CD):
#   export ARM_SUBSCRIPTION_ID="<subscription-id>"
#   export ARM_TENANT_ID="<tenant-id>"
#   export ARM_CLIENT_ID="<client-id>"
#   export ARM_CLIENT_SECRET="<client-secret>"
# =============================================================================

terraform {
  # TODO: Defina a versão mínima do Terraform
  # required_version = "~> 1.9.0"

  required_providers {
    # TODO: Configure o provider azurerm
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~> 3.110.0"
    # }

    # TODO: Configure o provider azuread (se necessário para AAD/Entra ID)
    # azuread = {
    #   source  = "hashicorp/azuread"
    #   version = "~> 2.53.0"
    # }

    # TODO: Configure o provider random (útil para gerar sufixos únicos)
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.6.0"
    # }
  }
}

# TODO: Configure o provider azurerm
# provider "azurerm" {
#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = true  # Proteção contra deleção acidental
#     }
#     key_vault {
#       purge_soft_delete_on_destroy    = false
#       recover_soft_deleted_key_vaults = true
#     }
#   }
# }
