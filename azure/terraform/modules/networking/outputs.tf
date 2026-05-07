# =============================================================================
# OUTPUTS - MODULE: NETWORKING
# =============================================================================

# TODO: Exporte os valores necessários para outros módulos

# output "vnet_id" {
#   description = "ID da Virtual Network criada."
#   value       = azurerm_virtual_network.main.id
# }

# output "vnet_name" {
#   description = "Nome da Virtual Network criada."
#   value       = azurerm_virtual_network.main.name
# }

# output "subnet_ids" {
#   description = "Mapa de IDs das subnets criadas (chave = nome lógico da subnet)."
#   value       = { for k, v in azurerm_subnet.subnets : k => v.id }
# }

# output "nsg_ids" {
#   description = "Mapa de IDs dos NSGs criados (chave = nome lógico da subnet)."
#   value       = { for k, v in azurerm_network_security_group.subnets : k => v.id }
# }
