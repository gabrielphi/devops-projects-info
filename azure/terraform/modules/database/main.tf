# =============================================================================
# MODULE: DATABASE
# =============================================================================
# Módulo responsável por bancos de dados gerenciados no Azure.
#
# Recursos que este módulo pode criar:
#   - Azure Database for PostgreSQL Flexible Server
#   - Azure Database for MySQL Flexible Server
#   - Azure SQL Database / SQL Managed Instance
#   - Azure Cosmos DB (NoSQL, MongoDB, Cassandra, etc.)
#   - Azure Cache for Redis
#   - Private DNS Zone + DNS Zone Virtual Network Link (para Private Endpoint)
#
# Documentação dos recursos:
#   - PostgreSQL Flexible: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
#   - MySQL Flexible:      https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server
#   - Azure SQL:           https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database
#   - Cosmos DB:           https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account
#   - Redis Cache:         https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache
#
# SKUs PostgreSQL Flexible Server:
#   - Burstable:   B_Standard_B1ms, B_Standard_B2s (dev/test)
#   - General:     GP_Standard_D2s_v3, GP_Standard_D4s_v3 (produção)
#   - Memory Opt:  MO_Standard_E4s_v3 (workloads intensivos)
#   - Guia:        https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage
# =============================================================================

# TODO: Private DNS Zone para PostgreSQL (necessário para Private Endpoint / VNet integration)
# resource "azurerm_private_dns_zone" "postgresql" {
#   name                = "${var.prefix}.private.postgres.database.azure.com"
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# TODO: Vincular DNS Zone à VNet
# resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
#   name                  = "vnet-link-postgresql"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
#   virtual_network_id    = var.vnet_id
#   tags                  = var.tags
# }

# TODO: PostgreSQL Flexible Server
# resource "azurerm_postgresql_flexible_server" "main" {
#   name                   = "psql-${var.prefix}"
#   resource_group_name    = var.resource_group_name
#   location               = var.location
#   version                = "16"
#   delegated_subnet_id    = var.subnet_id
#   private_dns_zone_id    = azurerm_private_dns_zone.postgresql.id
#   administrator_login    = var.admin_username
#   administrator_password = var.admin_password
#
#   storage_mb   = 32768
#   storage_tier = "P4"
#
#   sku_name = var.db_sku
#
#   backup_retention_days        = 7
#   geo_redundant_backup_enabled = false  # true para produção
#
#   high_availability {
#     mode = "Disabled"  # "ZoneRedundant" para produção
#   }
#
#   maintenance_window {
#     day_of_week  = 0  # Domingo
#     start_hour   = 2
#     start_minute = 0
#   }
#
#   lifecycle {
#     prevent_destroy = true  # Proteção contra deleção acidental em produção
#     ignore_changes  = [zone, high_availability[0].standby_availability_zone]
#   }
#
#   tags = var.tags
#
#   depends_on = [azurerm_private_dns_zone_virtual_network_link.postgresql]
# }
