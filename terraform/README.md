# Projeto Terraform - Magalu Cloud

Este projeto segue a estrutura de melhores práticas do Terraform com separação de ambientes e módulos reutilizáveis.

## 📁 Estrutura do Projeto

```
terraform/
├── providers.tf              # Configuração global do provider MGC
├── variables.tf              # Variáveis globais do provider
├── versions.tf              # Versões do Terraform e providers
├── terraform.tfvars         # Valores das variáveis (não versionado)
├── terraform.tfvars.example # Template de variáveis
├── bootstrap/               # Recursos de inicialização/bootstrap
│   ├── main.tf
│   └── variables.tf
├── environments/           # Configurações por ambiente
│   └── staging/
│       ├── main.tf         # Recursos do ambiente staging
│       ├── variables.tf    # Variáveis específicas do ambiente
│       └── outputs.tf      # Outputs do ambiente
└── modules/                # Módulos reutilizáveis
    └── database/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

## 🚀 Como Usar

### 1. Configuração Inicial

#### 1.1. Configurar Variáveis do Provider

As variáveis do provider já têm valores padrão definidos em `variables.tf` (raiz) e `environments/staging/variables.tf`.

**Opção 1: Usar valores padrão** (já configurados)
- Não é necessário fazer nada, os valores padrão serão usados

**Opção 2: Sobrescrever valores** (recomendado para produção)
- Crie um arquivo `terraform.tfvars` no diretório do ambiente:

```bash
cd terraform/environments/staging
# Criar terraform.tfvars com:
api_key         = "sua-api-key"
region          = "br-se1-a"
mgc_key_pair_id = "seu-key-pair-id"
mgc_key_pair_secret = "seu-key-pair-secret"
```

**Nota:** Arquivos `.tfvars` não são versionados por segurança (já estão no `.gitignore`).

#### 1.2. Inicializar o Terraform

Para trabalhar com um ambiente específico, navegue até o diretório do ambiente:

```bash
cd terraform/environments/staging
terraform init
```

Isso irá:
- Baixar o provider MGC (versão 0.41.0)
- Configurar os módulos locais
- Preparar o ambiente para execução

### 2. Trabalhando com Ambientes

#### 2.1. Ambiente Staging

```bash
# Navegar para o ambiente
cd terraform/environments/staging

# Verificar o plano de execução
terraform plan

# Aplicar as mudanças
terraform apply

# Ver os outputs
terraform output

# Destruir recursos (cuidado!)
terraform destroy
```

#### 2.2. Usando Variáveis Específicas do Ambiente

Você pode criar um arquivo `terraform.tfvars` dentro do diretório do ambiente para sobrescrever variáveis:

```bash
cd terraform/environments/staging
# Criar terraform.tfvars com valores específicos do staging
terraform plan -var-file="terraform.tfvars"
```

### 3. Trabalhando com Bootstrap

O diretório `bootstrap/` é usado para recursos que precisam ser criados antes dos ambientes (ex: buckets S3 para state, IAM roles, etc.):

```bash
cd terraform/bootstrap
terraform init
terraform plan
terraform apply
```

### 4. Desenvolvendo Módulos

Os módulos em `modules/` são reutilizáveis e podem ser usados em qualquer ambiente:

```hcl
module "database" {
  source = "../../modules/database"
  
  name   = "minha-instancia"
  user   = "admin"
  # ... outras variáveis
}
```

## 🔑 Conceitos Importantes

### Provider Global

- O provider está configurado na raiz (`providers.tf`) como referência
- Cada ambiente tem seu próprio `providers.tf` e `versions.tf` para funcionar de forma independente
- As variáveis do provider são definidas globalmente (raiz) e replicadas nos ambientes
- Valores podem ser sobrescritos por ambiente usando `terraform.tfvars`

### Separação de Ambientes

- Cada ambiente é um **diretório separado** dentro de `environments/`
- Cada ambiente pode ter suas próprias variáveis e outputs
- O state do Terraform é isolado por ambiente

### Módulos Reutilizáveis

- Módulos ficam em `modules/`
- Cada módulo deve ter: `main.tf`, `variables.tf`, `outputs.tf`
- Módulos podem declarar seus próprios `required_providers` em `versions.tf`

## 📝 Comandos Úteis

```bash
# Validar configuração
terraform validate

# Formatar código
terraform fmt

# Ver providers instalados
terraform providers

# Ver dependências
terraform graph

# Limpar cache (se necessário)
rm -rf .terraform
terraform init
```

## ⚠️ Boas Práticas

1. **Nunca commite** arquivos `.tfvars` com dados sensíveis
2. **Sempre** execute `terraform plan` antes de `apply`
3. **Use** backend remoto para state em produção
4. **Versionamento**: Use tags do Git para versionar sua infraestrutura
5. **Revisão**: Sempre revise o plan antes de aplicar mudanças

## 🔒 Segurança

- Arquivos `.tfvars` estão no `.gitignore`
- Variáveis sensíveis devem usar `sensitive = true`
- Considere usar secrets managers (ex: AWS Secrets Manager, HashiCorp Vault) para credenciais em produção

## 📚 Próximos Passos

1. Configure um backend remoto para o state (ex: S3, GCS, Azure Storage)
2. Adicione mais ambientes (ex: `production/`)
3. Crie mais módulos reutilizáveis conforme necessário
4. Configure CI/CD para validação automática

