# =============================================================================
# BACKEND - DEV ENVIRONMENT
# =============================================================================
# Configura o remote state no Azure Storage Account.
#
# Documentação:
#   - Terraform Backend AzureRM: https://developer.hashicorp.com/terraform/language/settings/backends/azurerm
#   - Azure Storage para state: https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
#
# Boas práticas:
#   - Use um Storage Account DEDICADO para state (separado da infra da aplicação)
#   - Habilite versionamento no container para histórico de state
#   - Habilite soft delete no Storage Account
#   - Use chave (key) diferente por ambiente: dev/terraform.tfstate, prod/terraform.tfstate
#   - Separe states por ambiente para evitar blast radius
#   - Use SAS token ou Managed Identity para autenticação (evite access keys)
#
# Como criar o Storage Account para state (via Azure CLI):
#   az group create --name rg-terraform-state --location eastus
#   az storage account create --name sttfstate<suffix> --resource-group rg-terraform-state --sku Standard_LRS --encryption-services blob
#   az storage container create --name tfstate --account-name sttfstate<suffix>
#
# Inicializar com backend config externo (recomendado):
#   terraform init -backend-config="backend.conf"
# =============================================================================

terraform {
  # TODO: Configure o backend remoto
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "sttfstate<unique-suffix>"
  #   container_name       = "tfstate"
  #   key                  = "dev/terraform.tfstate"
  #
  #   # Autenticação via Service Principal (variáveis de ambiente)
  #   # ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
  # }
}
