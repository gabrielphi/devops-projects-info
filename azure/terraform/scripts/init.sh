#!/usr/bin/env bash
# =============================================================================
# Script de inicialização do ambiente Terraform para Azure
# =============================================================================
# Uso:
#   ./scripts/init.sh <ambiente>
#   ./scripts/init.sh dev
#   ./scripts/init.sh staging
#   ./scripts/init.sh prod
# =============================================================================

set -euo pipefail

ENVIRONMENT="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../environments/${ENVIRONMENT}"

# Validação
if [[ -z "${ENVIRONMENT}" ]]; then
  echo "Erro: informe o ambiente (dev, staging, prod)"
  echo "Uso: ./scripts/init.sh <ambiente>"
  exit 1
fi

if [[ ! -d "${TERRAFORM_DIR}" ]]; then
  echo "Erro: ambiente '${ENVIRONMENT}' não encontrado em environments/"
  exit 1
fi

echo "==> Inicializando Terraform para ambiente: ${ENVIRONMENT}"
cd "${TERRAFORM_DIR}"

# Verificar se terraform.tfvars existe
if [[ ! -f "terraform.tfvars" ]]; then
  echo "AVISO: terraform.tfvars não encontrado."
  echo "  Copie o arquivo exemplo: cp terraform.tfvars.example terraform.tfvars"
  echo "  e preencha os valores."
  exit 1
fi

# Verificar variáveis de ambiente Azure
required_vars=("ARM_SUBSCRIPTION_ID" "ARM_TENANT_ID" "ARM_CLIENT_ID" "ARM_CLIENT_SECRET")
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "AVISO: Variável de ambiente '${var}' não definida."
    echo "  Configure as credenciais Azure antes de continuar."
  fi
done

# Inicializar Terraform
terraform init \
  -upgrade \
  -reconfigure

echo ""
echo "==> Terraform inicializado com sucesso!"
echo "    Próximos passos:"
echo "    1. terraform validate"
echo "    2. terraform plan"
echo "    3. terraform apply"
