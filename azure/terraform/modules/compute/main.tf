# =============================================================================
# MODULE: COMPUTE
# =============================================================================
# Módulo responsável por recursos de computação no Azure.
#
# Recursos que este módulo pode criar:
#   - Virtual Machines (Linux e Windows)
#   - Virtual Machine Scale Sets (VMSS)
#   - Network Interfaces
#   - Managed Disks
#   - Availability Sets / Proximity Placement Groups
#   - Azure Container Instances (ACI) - para containers simples
#
# Documentação dos recursos:
#   - Linux VM:     https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
#   - Windows VM:   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
#   - VMSS:         https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set
#   - Managed Disk: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
#
# Tamanhos de VM (SKUs) comuns no Azure:
#   - B-series (burstable): Standard_B2s, Standard_B4ms — dev/test
#   - D-series (general): Standard_D2s_v5, Standard_D4s_v5 — workloads gerais
#   - E-series (memory): Standard_E4s_v5 — workloads intensivos em memória
#   - F-series (compute): Standard_F4s_v2 — workloads intensivos em CPU
#   - Guia completo: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
#
# Imagens comuns (publisher/offer/sku):
#   - Ubuntu 22.04: Canonical / 0001-com-ubuntu-server-jammy / 22_04-lts-gen2
#   - RHEL 9:       RedHat / RHEL / 9-lvm-gen2
#   - Windows 2022: MicrosoftWindowsServer / WindowsServer / 2022-datacenter-azure-edition
# =============================================================================

# TODO: Network Interface para a VM
# resource "azurerm_network_interface" "main" {
#   name                = "nic-${var.prefix}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#
#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = var.subnet_id
#     private_ip_address_allocation = "Dynamic"
#   }
#
#   tags = var.tags
# }

# TODO: Linux Virtual Machine
# resource "azurerm_linux_virtual_machine" "main" {
#   name                = "vm-${var.prefix}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   size                = var.vm_size
#   admin_username      = var.admin_username
#
#   # Usar SSH key ao invés de senha (boas práticas de segurança)
#   disable_password_authentication = true
#
#   admin_ssh_key {
#     username   = var.admin_username
#     public_key = file(var.ssh_public_key_path)
#   }
#
#   network_interface_ids = [azurerm_network_interface.main.id]
#
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }
#
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }
#
#   # Habilitar identidade gerenciada (evitar secrets para autenticação com serviços Azure)
#   identity {
#     type = "SystemAssigned"
#   }
#
#   lifecycle {
#     ignore_changes = [
#       admin_ssh_key  # Evita drift quando a chave é atualizada externamente
#     ]
#   }
#
#   tags = var.tags
# }
