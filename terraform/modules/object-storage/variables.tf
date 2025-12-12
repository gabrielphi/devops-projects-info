variable "project_name" {
  type        = string
  description = "Nome do projeto para prefixo dos buckets"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Ambiente (staging, production, etc.)"
  default     = ""
}

variable "buckets" {
  type = map(object({
    name                = string
    versioning          = optional(bool, false)
    lock                = optional(bool, false)
    is_public           = optional(bool, false)  # Se true, bucket é público (leitura para todos), se false é privado
    enable_cors         = optional(bool, false)
    cors_config         = optional(object({
      allowed_methods  = list(string)
      allowed_origins  = list(string)
      allowed_headers  = optional(list(string), ["*"])
      max_age_seconds  = optional(number, 3600)
      expose_headers   = optional(list(string), [])
    }), null)
    policy_template     = optional(string, null)  # Caminho do template de policy customizado (sobrescreve is_public)
    policy_vars         = optional(map(string), {})  # Variáveis para o template
  }))
  description = "Mapa de buckets para criar. A chave é usada como identificador único."
  default     = {}
}

