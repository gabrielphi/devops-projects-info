# =============================================================================
# VARIABLES - MODULE: STORAGE
# =============================================================================

# variable "resource_group_name" { type = string }
# variable "location"            { type = string }
# variable "prefix"              { type = string }

# variable "replication_type" {
#   description = "Tipo de replicação do Storage Account (LRS, GRS, ZRS, GZRS)."
#   type        = string
#   default     = "LRS"
#   validation {
#     condition     = contains(["LRS", "GRS", "ZRS", "GZRS", "RAGRS", "RAGZRS"], var.replication_type)
#     error_message = "Tipo de replicação inválido."
#   }
# }

# variable "containers" {
#   description = "Mapa de containers a serem criados."
#   type = map(object({
#     access_type = string  # "private", "blob", "container"
#   }))
#   default = {}
# }

# variable "tags" { type = map(string); default = {} }
