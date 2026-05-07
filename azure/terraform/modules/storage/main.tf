# =============================================================================
# MODULE: STORAGE
# =============================================================================
# Módulo responsável por recursos de armazenamento no Azure.
#
# Recursos que este módulo pode criar:
#   - Storage Account
#   - Blob Containers
#   - File Shares
#   - Storage Queues
#   - Storage Tables
#   - Static Website hosting
#
# Documentação dos recursos:
#   - Storage Account:    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
#   - Blob Container:     https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
#   - Storage Lifecycle:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy
#
# SKUs (account_replication_type):
#   - LRS  — Locally Redundant Storage (1 região, 3 cópias) — dev/test
#   - GRS  — Geo-Redundant Storage (2 regiões) — produção
#   - ZRS  — Zone-Redundant Storage (3 zonas, 1 região) — alta disponibilidade
#   - GZRS — Geo-Zone-Redundant Storage — missão crítica
#   - Guia: https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
#
# account_tier:
#   - Standard — uso geral (blobs, files, queues, tables)
#   - Premium  — alta performance (SSDs), apenas blobs e files
# =============================================================================

# TODO: Storage Account
# resource "azurerm_storage_account" "main" {
#   name                     = "st${replace(var.prefix, "-", "")}"  # Sem hífens, max 24 chars
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = var.replication_type
#
#   # Segurança
#   https_traffic_only_enabled      = true
#   min_tls_version                 = "TLS1_2"
#   allow_nested_items_to_be_public = false  # Bloquear acesso público por padrão
#
#   # Soft delete para recuperação de dados
#   blob_properties {
#     delete_retention_policy {
#       days = 7
#     }
#     container_delete_retention_policy {
#       days = 7
#     }
#     versioning_enabled = true
#   }
#
#   tags = var.tags
# }

# TODO: Blob Containers (for_each para criar múltiplos)
# resource "azurerm_storage_container" "containers" {
#   for_each = var.containers
#
#   name                  = each.key
#   storage_account_name  = azurerm_storage_account.main.name
#   container_access_type = each.value.access_type  # "private", "blob", "container"
# }

# TODO: Lifecycle policy para gerenciar custos de armazenamento
# resource "azurerm_storage_management_policy" "main" {
#   storage_account_id = azurerm_storage_account.main.id
#
#   rule {
#     name    = "archive-old-blobs"
#     enabled = true
#     filters {
#       prefix_match = ["logs/"]
#       blob_types   = ["blockBlob"]
#     }
#     actions {
#       base_blob {
#         tier_to_cool_after_days_since_modification_greater_than    = 30
#         tier_to_archive_after_days_since_modification_greater_than = 90
#         delete_after_days_since_modification_greater_than          = 365
#       }
#     }
#   }
# }
