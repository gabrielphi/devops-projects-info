# =============================================================================
# MODULE: NETWORKING
# =============================================================================
# Módulo responsável por toda a infraestrutura de rede no Azure.
#
# Recursos que este módulo pode criar:
#   - Resource Group (opcional, pode receber um existente)
#   - Virtual Network (VNet)
#   - Subnets
#   - Network Security Groups (NSG) e associações
#   - Route Tables
#   - NAT Gateway (para saída de tráfego das subnets privadas)
#   - Public IP
#
# Documentação dos recursos:
#   - VNet:     https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
#   - Subnet:   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
#   - NSG:      https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
#   - NAT GW:   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway
#
# Conceitos Azure para estudo:
#   - Hub-Spoke topology: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke
#   - VNet Peering: https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview
#   - Private Endpoints: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
# =============================================================================

# TODO: Virtual Network
# resource "azurerm_virtual_network" "main" {
#   name                = "vnet-${var.prefix}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   address_space       = var.vnet_address_space
#   tags                = var.tags
# }

# TODO: Subnets (usando for_each para criar múltiplas subnets de forma dinâmica)
# resource "azurerm_subnet" "subnets" {
#   for_each = var.subnets
#
#   name                 = "snet-${each.key}-${var.prefix}"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = each.value.address_prefixes
# }

# TODO: Network Security Group por subnet
# resource "azurerm_network_security_group" "subnets" {
#   for_each = var.subnets
#
#   name                = "nsg-${each.key}-${var.prefix}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   tags                = var.tags
# }

# TODO: Associar NSG às subnets
# resource "azurerm_subnet_network_security_group_association" "subnets" {
#   for_each = var.subnets
#
#   subnet_id                 = azurerm_subnet.subnets[each.key].id
#   network_security_group_id = azurerm_network_security_group.subnets[each.key].id
# }
