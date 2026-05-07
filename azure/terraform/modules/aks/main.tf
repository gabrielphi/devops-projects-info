# =============================================================================
# MODULE: AKS (Azure Kubernetes Service)
# =============================================================================
# Módulo responsável por clusters Kubernetes no Azure.
#
# Recursos que este módulo pode criar:
#   - AKS Cluster (azurerm_kubernetes_cluster)
#   - Node Pools adicionais (azurerm_kubernetes_cluster_node_pool)
#   - Azure Container Registry (ACR)
#   - Role Assignment: AKS -> ACR (acrpull)
#   - Cluster Autoscaler configuration
#
# Documentação dos recursos:
#   - AKS Cluster:    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
#   - Node Pool:      https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
#   - ACR:            https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
#
# SKUs de Node Pools (VM sizes recomendados para AKS):
#   - Standard_D2s_v5 — 2 vCPU, 8 GB RAM (nó padrão)
#   - Standard_D4s_v5 — 4 vCPU, 16 GB RAM (workloads médios)
#   - Standard_D8s_v5 — 8 vCPU, 32 GB RAM (workloads intensivos)
#
# Conceitos AKS para estudo:
#   - Networking models (kubenet vs Azure CNI): https://learn.microsoft.com/en-us/azure/aks/concepts-network
#   - Cluster autoscaler: https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler
#   - Managed Identity no AKS: https://learn.microsoft.com/en-us/azure/aks/use-managed-identity
#   - Workload Identity: https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview
#   - Azure CNI Overlay: https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay
# =============================================================================

# TODO: Azure Container Registry
# resource "azurerm_container_registry" "main" {
#   name                = "acr${replace(var.prefix, "-", "")}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku                 = var.acr_sku  # "Basic", "Standard", "Premium"
#   admin_enabled       = false        # Usar Managed Identity, não admin credentials
#   tags                = var.tags
# }

# TODO: AKS Cluster
# resource "azurerm_kubernetes_cluster" "main" {
#   name                = "aks-${var.prefix}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   dns_prefix          = var.prefix
#   kubernetes_version  = var.kubernetes_version
#
#   # Identidade gerenciada (recomendado sobre Service Principal)
#   identity {
#     type = "SystemAssigned"
#   }
#
#   # Node Pool padrão (system pool — apenas workloads do sistema)
#   default_node_pool {
#     name                = "system"
#     vm_size             = "Standard_D2s_v5"
#     node_count          = 1
#     vnet_subnet_id      = var.subnet_id
#     os_disk_size_gb     = 128
#     os_disk_type        = "Managed"
#
#     # Apenas para system workloads
#     only_critical_addons_enabled = true
#
#     # Auto-scaling
#     enable_auto_scaling = true
#     min_count           = 1
#     max_count           = 3
#   }
#
#   # Networking com Azure CNI (melhor para produção)
#   network_profile {
#     network_plugin    = "azure"
#     network_policy    = "calico"
#     load_balancer_sku = "standard"
#   }
#
#   # Addons
#   oms_agent {
#     log_analytics_workspace_id = var.log_analytics_workspace_id
#   }
#
#   azure_policy_enabled             = true
#   role_based_access_control_enabled = true
#
#   tags = var.tags
# }

# TODO: User Node Pool para workloads de aplicação
# resource "azurerm_kubernetes_cluster_node_pool" "app" {
#   name                  = "app"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
#   vm_size               = var.app_node_vm_size
#   vnet_subnet_id        = var.subnet_id
#
#   enable_auto_scaling = true
#   min_count           = 1
#   max_count           = 10
#
#   tags = var.tags
# }

# TODO: Dar permissão ao AKS de fazer pull do ACR
# resource "azurerm_role_assignment" "aks_acr_pull" {
#   principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.main.id
#   skip_service_principal_aad_check = true
# }
