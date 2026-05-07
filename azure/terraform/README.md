# Terraform na Azure — Guia Completo de Estudo e Boas Práticas

> Template de projeto Terraform para Azure seguindo as melhores práticas de produção.
> Este repositório é um guia de estudo prático — os arquivos `.tf` contêm exemplos comentados que você descomenta e adapta.

---

## Sumário

1. [Estrutura do Projeto](#estrutura-do-projeto)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração Inicial](#configuração-inicial)
4. [Melhores Práticas](#melhores-práticas)
5. [Guia de Recursos Azure](#guia-de-recursos-azure)
6. [Módulos deste Projeto](#módulos-deste-projeto)
7. [Fluxo de Trabalho](#fluxo-de-trabalho)
8. [CI/CD com Terraform](#cicd-com-terraform)
9. [Segurança](#segurança)
10. [Comandos Úteis](#comandos-úteis)
11. [Referências e Documentação](#referências-e-documentação)

---

## Estrutura do Projeto

```
azure/terraform/
├── .gitignore                        # Ignora .tfvars, .terraform/, *.tfstate
├── .terraform-version                # Versão do Terraform (usado pelo tfenv)
├── README.md                         # Este arquivo
├── scripts/
│   ├── init.sh                       # Script de inicialização por ambiente
│   └── validate.sh                   # Script de validação (fmt + validate + tflint)
├── environments/                     # Um diretório por ambiente
│   ├── dev/                          # Ambiente de desenvolvimento
│   │   ├── backend.tf                # Configuração do remote state
│   │   ├── locals.tf                 # Valores computados locais (nomes, tags padrão)
│   │   ├── main.tf                   # Orquestra os módulos
│   │   ├── outputs.tf                # Valores exportados
│   │   ├── providers.tf              # Versões do Terraform e providers
│   │   ├── variables.tf              # Declaração de variáveis
│   │   └── terraform.tfvars.example  # Exemplo de valores (comitar; .tfvars não comitar)
│   ├── staging/                      # Idêntico ao dev — use CIDRs e SKUs diferentes
│   └── prod/                         # Idêntico ao dev — mais proteções habilitadas
└── modules/                          # Módulos reutilizáveis
    ├── networking/                   # VNet, Subnets, NSG, Route Tables
    ├── compute/                      # VMs Linux/Windows, VMSS
    ├── database/                     # PostgreSQL / MySQL / SQL / Cosmos DB
    ├── storage/                      # Storage Account, Blob Containers
    ├── security/                     # Key Vault, Managed Identity, Log Analytics
    └── aks/                          # Kubernetes (AKS) + ACR
```

**Por que separar por ambiente?**
Cada ambiente (`dev`, `staging`, `prod`) possui seu próprio **state file** remoto. Isso garante que um `terraform apply` em dev nunca afete a produção. É o padrão mais recomendado para times pequenos e médios.

---

## Pré-requisitos

### Ferramentas obrigatórias

| Ferramenta | Versão mínima | Instalação |
|---|---|---|
| Terraform | 1.9.x | [developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install) |
| Azure CLI | 2.60+ | [learn.microsoft.com/en-us/cli/azure/install-azure-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| tfenv (opcional) | qualquer | [github.com/tfutils/tfenv](https://github.com/tfutils/tfenv) — gerencia versões do Terraform |

### Ferramentas recomendadas

| Ferramenta | Finalidade | Link |
|---|---|---|
| tflint | Linting e validação avançada | [github.com/terraform-linters/tflint](https://github.com/terraform-linters/tflint) |
| tfsec / trivy | Security scanning do código Terraform | [github.com/aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| terraform-docs | Gera documentação automática de módulos | [terraform-docs.io](https://terraform-docs.io) |
| checkov | Análise estática de segurança | [checkov.io](https://www.checkov.io) |

### Conta Azure

Você precisa de:
- Uma **subscription Azure** ativa ([Portal Azure](https://portal.azure.com) — crie uma conta gratuita com $200 de crédito)
- Um **Service Principal** com permissões de Contributor na subscription (para CI/CD)
- Ou usar **az login** para autenticação local (desenvolvimento)

---

## Configuração Inicial

### 1. Autenticação no Azure

**Opção A — Login interativo (desenvolvimento local):**
```bash
az login
az account set --subscription "<subscription-id>"
```

**Opção B — Service Principal (CI/CD ou automação):**
```bash
# Criar Service Principal
az ad sp create-for-rbac \
  --name "sp-terraform-<projeto>" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id>

# Exportar as credenciais geradas como variáveis de ambiente
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
```

> **Boas práticas:** Nunca salve credenciais em arquivos. Use variáveis de ambiente, Azure Key Vault ou o secret store do seu CI/CD (GitHub Actions Secrets, Azure DevOps Variable Groups).

### 2. Criar Storage Account para Remote State

O Terraform precisa de um lugar para guardar o **state file** remotamente. Crie antes de tudo:

```bash
# Grupo de recursos dedicado ao state (separado da infra da aplicação)
az group create \
  --name rg-terraform-state \
  --location eastus

# Storage Account (nome globalmente único, sem hífens, máx 24 chars)
az storage account create \
  --name sttfstate$(openssl rand -hex 4) \
  --resource-group rg-terraform-state \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2

# Container para os state files
az storage container create \
  --name tfstate \
  --account-name <nome-do-storage-account>
```

> Anote o nome do Storage Account — você vai precisar configurar no `backend.tf` de cada ambiente.

### 3. Configurar um Ambiente

```bash
cd environments/dev

# Copiar o arquivo de variáveis
cp terraform.tfvars.example terraform.tfvars

# Editar com seus valores reais
# (nunca comitar este arquivo — está no .gitignore)
nano terraform.tfvars

# Editar backend.tf com o nome do seu Storage Account
nano backend.tf

# Inicializar
terraform init

# Validar
terraform validate

# Ver o plano de mudanças
terraform plan

# Aplicar (somente após revisar o plan com atenção!)
terraform apply
```

---

## Melhores Práticas

### 1. Estrutura de Arquivos Consistente

Cada diretório (ambiente ou módulo) deve ter os mesmos arquivos com responsabilidades bem definidas:

| Arquivo | Responsabilidade |
|---|---|
| `providers.tf` | Versões do Terraform e dos providers |
| `backend.tf` | Configuração do remote state |
| `variables.tf` | Declaração de variáveis (com description, type, validation) |
| `locals.tf` | Valores computados, nomes de recursos, tags padrão |
| `main.tf` | Orquestração dos módulos (sem recursos diretos quando possível) |
| `outputs.tf` | Valores exportados para outros módulos ou para o operador |
| `terraform.tfvars.example` | Exemplo de valores (comitar no repositório) |

Para ambientes complexos, divida o `main.tf` por tipo de recurso:
```
network.tf    # VNet, subnets, NSG
compute.tf    # VMs, VMSS
database.tf   # PostgreSQL, Redis
security.tf   # Key Vault, RBAC
```

### 2. Sempre Pin Versões

```hcl
# providers.tf
terraform {
  required_version = "~> 1.9.0"   # Permite 1.9.x, bloqueia 2.x

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"       # Permite 3.110.x, bloqueia 4.x
    }
  }
}
```

O operador `~>` (pessimistic constraint) é a chave:
- `~> 1.9.0` = aceita `1.9.0`, `1.9.1`, `1.9.9` — bloqueia `1.10.0`
- `~> 1.9`   = aceita `1.9`, `1.10`, `1.99` — bloqueia `2.0`

Sempre comite o arquivo `.terraform.lock.hcl` gerado pelo `terraform init`.

### 3. Nomenclatura de Recursos

Siga a [Naming Convention oficial da Microsoft](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming):

```hcl
locals {
  prefix = "${var.project_name}-${var.environment}"

  names = {
    resource_group    = "rg-${local.prefix}-${var.location}"
    virtual_network   = "vnet-${local.prefix}"
    subnet            = "snet-<purpose>-${local.prefix}"
    nsg               = "nsg-<purpose>-${local.prefix}"
    vm                = "vm-${local.prefix}-<index>"
    key_vault         = "kv-${local.prefix}"
    aks               = "aks-${local.prefix}"
    acr               = "acr${replace(local.prefix, "-", "")}"   # Sem hífens
    storage_account   = "st${replace(local.prefix, "-", "")}"    # Sem hífens, max 24 chars
    postgresql        = "psql-${local.prefix}"
    log_analytics     = "log-${local.prefix}"
  }
}
```

**Abreviações oficiais Microsoft:** [aka.ms/azabbr](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

### 4. Tags em Todos os Recursos

Tags são essenciais para governança, custo e rastreabilidade:

```hcl
locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "github.com/empresa/repo"
    Owner       = "time-devops@empresa.com"
  })
}
```

Aplique `tags = local.common_tags` em todos os recursos que suportam tags.

### 5. Validação de Variáveis

Capture erros de configuração cedo com `validation` blocks:

```hcl
variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser 'dev', 'staging' ou 'prod'."
  }
}

variable "location" {
  description = "Azure region."
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus2", "brazilsouth",
      "westeurope", "northeurope", "southeastasia"
    ], var.location)
    error_message = "Região Azure inválida ou não suportada."
  }
}
```

### 6. for_each vs count

Prefira `for_each` ao `count` para recursos com identidade própria:

```hcl
# RUIM — usar count com lista
resource "azurerm_subnet" "subnets" {
  count = length(var.subnets)
  name  = var.subnets[count.index].name
  # Se remover o item do meio da lista, Terraform recria todos os subsequentes!
}

# BOM — usar for_each com mapa
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name     = each.key
  # Remover uma entry do mapa afeta APENAS aquele recurso
}
```

Use `count` apenas para recursos sem identidade própria (ex: repetir um bloco simples).

### 7. Data Sources ao invés de Hardcode

```hcl
# RUIM — hardcode
resource "azurerm_subnet" "aks" {
  virtual_network_name = "vnet-meu-projeto-dev"
  # E se o nome mudar?
}

# BOM — data source
data "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "aks" {
  virtual_network_name = data.azurerm_virtual_network.main.name
}
```

### 8. Lifecycle Rules para Proteção

```hcl
resource "azurerm_postgresql_flexible_server" "main" {
  # ...

  lifecycle {
    # Impede deleção acidental (erro se tentar destruir)
    prevent_destroy = true

    # Ignora mudanças em campos que o Azure gerencia automaticamente
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
    ]

    # Cria o novo antes de destruir o antigo (zero downtime)
    create_before_destroy = true
  }
}
```

### 9. Separação de State por Ambiente

```
# dev state
environments/dev/backend.tf   → key = "dev/terraform.tfstate"

# staging state
environments/staging/backend.tf → key = "staging/terraform.tfstate"

# prod state
environments/prod/backend.tf  → key = "prod/terraform.tfstate"
```

Nunca misture recursos de ambientes diferentes no mesmo state file.

### 10. Variáveis Sensíveis

```hcl
# variables.tf
variable "db_password" {
  description = "Senha do banco de dados."
  type        = string
  sensitive   = true  # Mascara nos logs e outputs
}

# outputs.tf — marcar outputs sensíveis também
output "connection_string" {
  value     = "postgresql://user:${var.db_password}@${azurerm_postgresql_flexible_server.main.fqdn}"
  sensitive = true
}
```

Para produção, **nunca passe senhas como variáveis Terraform**. Use [Azure Key Vault com data source](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret):

```hcl
data "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  key_vault_id = azurerm_key_vault.main.id
}
```

---

## Guia de Recursos Azure

### Hierarquia de Recursos Azure

```
Tenant (Azure AD / Entra ID)
└── Subscription
    ├── Resource Group           ← Unidade de gerenciamento lógico
    │   ├── Virtual Network (VNet)
    │   │   ├── Subnet
    │   │   └── Subnet
    │   ├── Virtual Machine
    │   ├── Storage Account
    │   └── ... outros recursos
    └── Resource Group
        └── ...
```

Todo recurso Azure vive dentro de um **Resource Group**. O Resource Group é a unidade de deploy, billing e lifecycle.

### Regiões Azure

As principais regiões para workloads no Brasil/América Latina:

| Região | Location Code | Notas |
|---|---|---|
| Brazil South | `brazilsouth` | São Paulo — para dados que precisam ficar no Brasil (LGPD) |
| East US | `eastus` | Virginia — mais serviços disponíveis, menor custo |
| East US 2 | `eastus2` | Virginia — par de replicação do East US |
| West US 2 | `westus2` | Washington |
| West Europe | `westeurope` | Holanda |

Verifique disponibilidade de serviços por região: [azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/)

---

### Recursos Fundamentais

#### Resource Group
- **Doc Terraform:** [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- **Conceito Azure:** [learn.microsoft.com — Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- Agrupa recursos com o mesmo lifecycle. Delete o Resource Group para deletar tudo dentro dele.

#### Virtual Network (VNet)
- **Doc Terraform:** [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- **Conceito Azure:** [learn.microsoft.com — VNet Overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- Rede privada isolada no Azure. Use CIDRs privados: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`.
- **VNet Peering** conecta duas VNets.
- **Private Endpoints** conectam serviços PaaS à sua VNet via IP privado.

#### Subnets
- **Doc Terraform:** [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- Divisão lógica da VNet. Separe por camada: `snet-frontend`, `snet-backend`, `snet-database`, `snet-aks`.
- Algumas subnets precisam de **delegation** (ex: para PostgreSQL Flexible Server ou AKS com Azure CNI).

#### Network Security Group (NSG)
- **Doc Terraform:** [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- **Conceito Azure:** [learn.microsoft.com — NSG Overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- Firewall stateful no nível de subnet ou NIC. Define regras de entrada/saída.
- Prioridade: 100 (menor = maior prioridade), 65000-65535 são regras default do Azure.

---

### Compute

#### Virtual Machine (VM)
- **Doc Terraform Linux:** [azurerm_linux_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)
- **Doc Terraform Windows:** [azurerm_windows_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine)
- **Tamanhos de VM:** [learn.microsoft.com — VM Sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- **Séries de VM e casos de uso:**
  - **B-series (Burstable):** `Standard_B2s` — dev/test, workloads que não precisam de CPU constante
  - **D-series (General Purpose):** `Standard_D4s_v5` — produção, workloads web
  - **E-series (Memory Optimized):** `Standard_E4s_v5` — bancos in-memory, Java
  - **F-series (Compute Optimized):** `Standard_F4s_v2` — processamento batch, gaming

#### Virtual Machine Scale Set (VMSS)
- **Doc Terraform:** [azurerm_linux_virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
- Auto-scaling horizontal de VMs. Use para workloads sem estado que precisam escalar.

#### Azure Kubernetes Service (AKS)
- **Doc Terraform:** [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- **Conceito Azure:** [learn.microsoft.com — AKS Overview](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes)
- Kubernetes gerenciado — o control plane é gerenciado pela Microsoft.
- **Modelos de rede:**
  - **kubenet:** IP privado só dentro do cluster; NAT para comunicação externa. Simples, menos IPs.
  - **Azure CNI:** Cada pod recebe um IP da VNet. Melhor para integração com serviços Azure.
  - **Azure CNI Overlay:** Melhor dos dois mundos — pods em IPs privados overlay, menos consumo de IPs.
- **Node Pools:** Separe system pool (infra do cluster) de user pools (aplicações).

---

### Database

#### Azure Database for PostgreSQL Flexible Server
- **Doc Terraform:** [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- **Conceito Azure:** [learn.microsoft.com — PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview)
- Requer **delegated subnet** e **Private DNS Zone** para acesso via rede privada.
- SKUs: Burstable (dev), General Purpose (prod), Memory Optimized (analytics).

#### Azure SQL Database
- **Doc Terraform:** [azurerm_mssql_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)
- **Conceito Azure:** [learn.microsoft.com — Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)
- Modelos de compra: DTU (simples, previsível) ou vCore (flexível, recomendado).
- Serverless tier: escala automaticamente, ótimo para dev/test.

#### Azure Cosmos DB
- **Doc Terraform:** [azurerm_cosmosdb_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account)
- **Conceito Azure:** [learn.microsoft.com — Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction)
- Banco NoSQL multi-modelo: Core (SQL), MongoDB, Cassandra, Gremlin, Table.
- Distribuição global com replicação automática.

#### Azure Cache for Redis
- **Doc Terraform:** [azurerm_redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
- Cache in-memory. SKUs: C0-C6 (Basic/Standard), P1-P5 (Premium com clustering).

---

### Storage

#### Storage Account
- **Doc Terraform:** [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- **Conceito Azure:** [learn.microsoft.com — Storage Account Overview](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- Tipos de serviço: **Blob** (objetos), **Files** (SMB/NFS), **Queues** (mensageria), **Tables** (NoSQL simples).
- **Redundância:** LRS (dev) → ZRS (HA) → GRS (disaster recovery) → GZRS (crítico).
- Nome: apenas letras minúsculas e números, 3-24 caracteres, globalmente único.

#### Blob Storage
- **Tiers de acesso:**
  - **Hot:** dados acessados frequentemente
  - **Cool:** dados acessados com menos frequência (30+ dias) — custo de armazenamento menor, custo de acesso maior
  - **Archive:** dados raramente acessados (180+ dias) — mais barato, acesso lento (horas)
- **Lifecycle policies:** automatize a migração entre tiers para reduzir custos.

---

### Segurança e Identidade

#### Azure Key Vault
- **Doc Terraform:** [azurerm_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- **Conceito Azure:** [learn.microsoft.com — Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- Armazena: **secrets** (senhas, connection strings), **keys** (criptografia), **certificates** (TLS).
- Use **RBAC** ao invés de Access Policies (mais granular e auditável).
- **Soft delete + Purge Protection:** obrigatório em produção para evitar perda acidental de dados.

#### Managed Identities
- **Conceito Azure:** [learn.microsoft.com — Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- Identidade gerenciada automaticamente pelo Azure — sem credenciais para gerenciar.
- **System-Assigned:** 1:1 com o recurso, destruída junto com ele.
- **User-Assigned:** independente, pode ser associada a múltiplos recursos. Preferida para aplicações.
- Substitui Service Principals e connection strings com credenciais hardcodadas.

#### RBAC (Role-Based Access Control)
- **Conceito Azure:** [learn.microsoft.com — Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)
- **Doc Terraform:** [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)
- Roles built-in comuns:
  - `Owner` — controle total incluindo acesso
  - `Contributor` — cria/modifica recursos, sem gerenciar acesso
  - `Reader` — somente leitura
  - `Key Vault Secrets User` — leitura de secrets
  - `AcrPull` — pull de imagens do Container Registry
  - `Storage Blob Data Contributor` — leitura e escrita em blobs

#### Log Analytics Workspace
- **Doc Terraform:** [azurerm_log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace)
- Central de logs do Azure Monitor. Quase todos os serviços Azure enviam logs aqui.
- Use para: diagnóstico, alertas, dashboards (Azure Workbooks), integração com Microsoft Sentinel (SIEM).

---

## Módulos deste Projeto

### networking
Cria a infraestrutura de rede base:
- Virtual Network com CIDRs configuráveis
- Subnets via `for_each` (dinâmico)
- NSG por subnet com regras básicas

**Estudo recomendado:**
- [Hub-Spoke network topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Private Endpoint overview](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)

### compute
Cria Virtual Machines Linux com boas práticas:
- SSH key (sem password authentication)
- Managed Disk Premium
- System-Assigned Managed Identity
- Lifecycle com `ignore_changes`

**Estudo recomendado:**
- [Sizes for VMs in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Azure VM extensions](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/overview)

### database
Cria PostgreSQL Flexible Server com:
- VNet integration via delegated subnet
- Private DNS Zone
- Backup e maintenance window configuráveis
- `prevent_destroy` para produção

**Estudo recomendado:**
- [PostgreSQL Flexible Server networking](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking)
- [High availability options](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-high-availability)

### storage
Cria Storage Account com:
- HTTPS-only e TLS 1.2 mínimo
- Acesso público bloqueado por padrão
- Soft delete habilitado
- Lifecycle policies para gerenciamento de custos

**Estudo recomendado:**
- [Storage redundancy](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)
- [Blob storage access tiers](https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview)

### security
Cria recursos de segurança:
- Key Vault com RBAC e Purge Protection
- User-Assigned Managed Identity
- Log Analytics Workspace
- Role Assignments

**Estudo recomendado:**
- [Key Vault best practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Managed identities best practices](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations)

### aks
Cria cluster AKS com:
- System-Assigned Managed Identity
- System node pool isolado (critical addons only)
- User node pool com autoscaler
- Azure CNI networking
- Azure Container Registry com permissão AcrPull automática
- Log Analytics integration

**Estudo recomendado:**
- [AKS baseline architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
- [AKS security hardening](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-security)
- [Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)

---

## Fluxo de Trabalho

### Desenvolvimento diário

```
Escrever código → fmt → validate → plan → review → apply
```

```bash
# 1. Formatar o código
terraform fmt -recursive

# 2. Validar sintaxe
terraform validate

# 3. Ver mudanças
terraform plan -out=tfplan.out

# 4. Revisar o plano com atenção!
#    Verifique: quais recursos serão criados/modificados/destruídos

# 5. Aplicar
terraform apply tfplan.out
```

### Workflow por Pull Request

```
feature branch → PR → CI valida (fmt + validate + plan) → review → merge → CD aplica
```

**Nunca aplique diretamente em produção sem PR review.**

### Destruir recursos (com cuidado)

```bash
# Ver o que será destruído
terraform plan -destroy

# Destruir (requer confirmação interativa)
terraform destroy

# NÃO use -auto-approve em produção
```

---

## CI/CD com Terraform

### GitHub Actions — Exemplo de Pipeline

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    branches: [main]
    paths: ['azure/terraform/**']
  push:
    branches: [main]
    paths: ['azure/terraform/**']

env:
  ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
  ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
  TF_VERSION: "1.9.0"

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        working-directory: azure/terraform

      - name: Terraform Init
        run: terraform init
        working-directory: azure/terraform/environments/dev

      - name: Terraform Validate
        run: terraform validate
        working-directory: azure/terraform/environments/dev

  plan:
    needs: validate
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Plan
        run: |
          terraform init
          terraform plan -no-color
        working-directory: azure/terraform/environments/dev

  apply:
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production  # Requer aprovação manual no GitHub
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Apply
        run: |
          terraform init
          terraform apply -auto-approve
        working-directory: azure/terraform/environments/prod
```

**Documentação GitHub Actions:** [docs.github.com](https://docs.github.com/en/actions)
**Azure DevOps Pipelines com Terraform:** [learn.microsoft.com](https://learn.microsoft.com/en-us/azure/developer/terraform/overview-azdo)

---

## Segurança

### Checklist de Segurança

- [ ] Credenciais nunca hardcodadas — usar variáveis de ambiente ou Key Vault
- [ ] `terraform.tfvars` no `.gitignore` (contém valores reais)
- [ ] `.terraform.lock.hcl` commitado (garante reproducibilidade)
- [ ] Outputs sensíveis marcados com `sensitive = true`
- [ ] `purge_protection_enabled = true` no Key Vault (produção)
- [ ] `prevent_destroy = true` em recursos críticos (produção)
- [ ] `https_traffic_only_enabled = true` no Storage Account
- [ ] `min_tls_version = "TLS1_2"` em todos os recursos que suportam
- [ ] Acesso público bloqueado por padrão (Storage, Key Vault)
- [ ] Managed Identity ao invés de Service Principal com senha
- [ ] RBAC com princípio do menor privilégio
- [ ] NSGs configurados em todas as subnets
- [ ] Logs enviados ao Log Analytics Workspace

### Ferramentas de Segurança

```bash
# Trivy — escaneia o código Terraform por vulnerabilidades e misconfigurations
trivy config azure/terraform/

# Checkov — análise estática de segurança
checkov -d azure/terraform/

# tfsec (agora integrado ao Trivy)
tfsec azure/terraform/
```

---

## Comandos Úteis

### Terraform

```bash
# Formatar código
terraform fmt -recursive

# Validar
terraform validate

# Inicializar (com upgrade dos providers)
terraform init -upgrade

# Planejar e salvar o plano
terraform plan -out=tfplan.out

# Aplicar o plano salvo
terraform apply tfplan.out

# Ver o state atual
terraform show

# Listar recursos no state
terraform state list

# Ver detalhes de um recurso no state
terraform state show azurerm_resource_group.main

# Importar recurso existente para o state
terraform import azurerm_resource_group.main /subscriptions/<sub-id>/resourceGroups/<rg-name>

# Remover recurso do state (sem destruir o recurso real)
terraform state rm azurerm_resource_group.old

# Mover recurso no state (ex: após refatoração)
terraform state mv azurerm_subnet.old azurerm_subnet.new

# Destruir recurso específico
terraform destroy -target=azurerm_resource_group.main

# Gerar grafo de dependências (requer graphviz)
terraform graph | dot -Tsvg > graph.svg
```

### Azure CLI úteis para Terraform

```bash
# Listar subscriptions
az account list --output table

# Definir subscription ativa
az account set --subscription "<subscription-id>"

# Listar regiões disponíveis
az account list-locations --output table

# Listar versões de Kubernetes disponíveis
az aks get-versions --location eastus --output table

# Listar SKUs de VM disponíveis em uma região
az vm list-skus --location eastus --size Standard_D --output table

# Listar imagens do marketplace
az vm image list --publisher Canonical --offer ubuntu --all --output table

# Ver quotas de recursos por região
az vm list-usage --location eastus --output table

# Verificar se o nome do Storage Account está disponível (globalmente único)
az storage account check-name --name meuprojetostg

# Obter object ID do usuário atual (útil para role assignments)
az ad signed-in-user show --query id --output tsv
```

---

## Referências e Documentação

### Terraform

| Recurso | Link |
|---|---|
| Documentação oficial Terraform | [developer.hashicorp.com/terraform/docs](https://developer.hashicorp.com/terraform/docs) |
| Terraform Registry (providers e módulos) | [registry.terraform.io](https://registry.terraform.io) |
| Provider AzureRM | [registry.terraform.io/providers/hashicorp/azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) |
| Terraform Language Reference | [developer.hashicorp.com/terraform/language](https://developer.hashicorp.com/terraform/language) |
| Terraform Best Practices | [developer.hashicorp.com/terraform/cloud-docs/recommended-practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices) |
| 10 Best Practices (devops-daily) | [devops-daily.com — 10 Best Practices](https://devops-daily.com/guides/introduction-to-terraform/10-best-practices-and-production-patterns) |

### Azure

| Recurso | Link |
|---|---|
| Portal Azure | [portal.azure.com](https://portal.azure.com) |
| Documentação Azure | [learn.microsoft.com/en-us/azure](https://learn.microsoft.com/en-us/azure) |
| Azure Architecture Center | [learn.microsoft.com/en-us/azure/architecture](https://learn.microsoft.com/en-us/azure/architecture) |
| Cloud Adoption Framework (CAF) | [learn.microsoft.com/en-us/azure/cloud-adoption-framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework) |
| Naming conventions | [learn.microsoft.com — Resource Naming](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) |
| Abbreviations (siglas) | [learn.microsoft.com — Abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) |
| Pricing Calculator | [azure.microsoft.com/en-us/pricing/calculator](https://azure.microsoft.com/en-us/pricing/calculator/) |
| Azure Free Account | [azure.microsoft.com/en-us/free](https://azure.microsoft.com/en-us/free/) |

### Cursos e Certificações

| Recurso | Link |
|---|---|
| Microsoft Learn (gratuito) | [learn.microsoft.com](https://learn.microsoft.com) |
| AZ-900 — Azure Fundamentals | [learn.microsoft.com/en-us/credentials/certifications/azure-fundamentals](https://learn.microsoft.com/en-us/credentials/certifications/azure-fundamentals/) |
| AZ-104 — Azure Administrator | [learn.microsoft.com/en-us/credentials/certifications/azure-administrator](https://learn.microsoft.com/en-us/credentials/certifications/azure-administrator/) |
| HashiCorp Terraform Associate | [developer.hashicorp.com/certifications/infrastructure-automation](https://developer.hashicorp.com/certifications/infrastructure-automation) |
| Terraform on Azure (Microsoft Learn) | [learn.microsoft.com/en-us/azure/developer/terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/) |

### Módulos da Comunidade

> Módulos prontos e validados pela comunidade. Use como referência ou como base.

| Módulo | Link |
|---|---|
| AKS (Azure Verified Module) | [registry.terraform.io/modules/Azure/aks](https://registry.terraform.io/modules/Azure/aks/azurerm/latest) |
| Azure — módulos oficiais Microsoft | [registry.terraform.io/namespaces/Azure](https://registry.terraform.io/namespaces/Azure) |
| Azure Verified Modules | [azure.github.io/Azure-Verified-Modules](https://azure.github.io/Azure-Verified-Modules/) |

---

## Como Estudar com Este Projeto

1. **Leia** este README do início ao fim para ter o mapa mental completo.
2. **Explore** os módulos em `modules/` — cada `main.tf` tem comentários explicando cada recurso e links para a documentação.
3. **Configure** um ambiente `dev` real:
   - Crie uma conta Azure gratuita
   - Configure o Storage Account para remote state
   - Copie `terraform.tfvars.example` para `terraform.tfvars`
   - Descomente um recurso de cada vez (comece pelo Resource Group)
   - Execute `terraform plan` e `terraform apply`
4. **Experimente** os recursos: crie uma VNet, depois uma subnet, depois uma VM simples.
5. **Destrua** tudo com `terraform destroy` para não gerar custos.
6. **Avance** para AKS e bancos de dados após dominar os recursos básicos.

> A melhor forma de aprender Terraform é criando recursos reais, errando, lendo os erros e consertando.
