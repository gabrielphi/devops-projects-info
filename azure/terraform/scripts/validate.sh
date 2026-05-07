#!/usr/bin/env bash
# =============================================================================
# Script de validação do código Terraform
# =============================================================================
# Executa: fmt check, validate e tflint em todos os ambientes e módulos.
# Uso:
#   ./scripts/validate.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

echo "==> Verificando formatação (terraform fmt)..."
terraform fmt -check -recursive "${ROOT_DIR}"
echo "    OK"

echo ""
echo "==> Validando módulos..."
for module_dir in "${ROOT_DIR}"/modules/*/; do
  module_name=$(basename "${module_dir}")
  echo "    Validando módulo: ${module_name}"
  cd "${module_dir}"
  terraform init -backend=false -no-color > /dev/null 2>&1
  terraform validate -no-color
  cd - > /dev/null
done

echo ""
echo "==> Validando ambientes..."
for env_dir in "${ROOT_DIR}"/environments/*/; do
  env_name=$(basename "${env_dir}")
  echo "    Validando ambiente: ${env_name}"
  cd "${env_dir}"
  # Inicializa sem backend para validação local
  terraform init -backend=false -no-color > /dev/null 2>&1
  terraform validate -no-color
  cd - > /dev/null
done

echo ""
echo "==> Todas as validações passaram com sucesso!"

# Verificar se tflint está instalado
if command -v tflint &> /dev/null; then
  echo ""
  echo "==> Executando tflint..."
  cd "${ROOT_DIR}"
  tflint --recursive
  echo "    tflint OK"
else
  echo ""
  echo "AVISO: tflint não instalado. Instale em: https://github.com/terraform-linters/tflint"
fi
