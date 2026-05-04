# =============================================================================
# OUTPUTS - PROD ENVIRONMENT
# =============================================================================
# Defina os valores de saída do ambiente.
#
# Documentação:
#   - Outputs: https://developer.hashicorp.com/terraform/language/values/outputs
#
# Boas práticas:
#   - Exporte apenas o que for necessário para outros módulos ou para o operador
#   - Marque outputs sensíveis com sensitive = true
#   - Prefira referenciar outputs de módulos ao invés de hardcode
#   - Use outputs para integração entre ambientes ou pipelines CI/CD
# =============================================================================

# TODO: Defina os outputs do ambiente

# output "resource_group_name" {
#   description = "Nome do Resource Group principal."
#   value       = module.networking.resource_group_name
# }

# output "vnet_id" {
#   description = "ID da Virtual Network."
#   value       = module.networking.vnet_id
# }

# output "vnet_name" {
#   description = "Nome da Virtual Network."
#   value       = module.networking.vnet_name
# }

# output "subnet_ids" {
#   description = "Mapa de IDs das subnets criadas."
#   value       = module.networking.subnet_ids
# }

# output "db_connection_string" {
#   description = "Connection string do banco de dados."
#   value       = module.database.connection_string
#   sensitive   = true
# }

# output "aks_cluster_name" {
#   description = "Nome do cluster AKS."
#   value       = module.aks.cluster_name
# }

# output "aks_kube_config" {
#   description = "Kubeconfig do cluster AKS."
#   value       = module.aks.kube_config
#   sensitive   = true
# }
