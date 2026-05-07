# =============================================================================
# VARIABLES - MODULE: AKS
# =============================================================================

# variable "resource_group_name"        { type = string }
# variable "location"                   { type = string }
# variable "prefix"                     { type = string }
# variable "subnet_id"                  { type = string }
# variable "log_analytics_workspace_id" { type = string }

# variable "kubernetes_version" {
#   description = "Versão do Kubernetes. Use 'az aks get-versions --location eastus' para listar versões disponíveis."
#   type        = string
#   default     = "1.30"
# }

# variable "acr_sku" {
#   description = "SKU do Azure Container Registry."
#   type        = string
#   default     = "Standard"
#   validation {
#     condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
#     error_message = "SKU do ACR deve ser Basic, Standard ou Premium."
#   }
# }

# variable "app_node_vm_size" {
#   description = "Tamanho das VMs do node pool de aplicação."
#   type        = string
#   default     = "Standard_D4s_v5"
# }

# variable "tags" { type = map(string); default = {} }
