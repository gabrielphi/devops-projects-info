# =============================================================================
# OUTPUTS - MODULE: AKS
# =============================================================================

# output "cluster_name" {
#   description = "Nome do cluster AKS."
#   value       = azurerm_kubernetes_cluster.main.name
# }

# output "cluster_id" {
#   description = "ID do cluster AKS."
#   value       = azurerm_kubernetes_cluster.main.id
# }

# output "kube_config" {
#   description = "Kubeconfig para acesso ao cluster."
#   value       = azurerm_kubernetes_cluster.main.kube_config_raw
#   sensitive   = true
# }

# output "host" {
#   description = "API server do cluster AKS."
#   value       = azurerm_kubernetes_cluster.main.kube_config[0].host
#   sensitive   = true
# }

# output "acr_login_server" {
#   description = "Login server do Azure Container Registry."
#   value       = azurerm_container_registry.main.login_server
# }

# output "identity_principal_id" {
#   description = "Principal ID da Managed Identity do AKS (para role assignments)."
#   value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
# }
