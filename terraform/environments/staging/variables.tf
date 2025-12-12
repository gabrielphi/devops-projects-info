variable "api_key" {
  type        = string
  sensitive   = true
  description = "The Magalu Cloud API Key"
  default     = ""
}

variable "mgc_key_pair_id" {
  type        = string
  sensitive   = true
  description = "The Magalu Cloud key pair id"
  default     = ""
}

variable "mgc_key_pair_secret" { 
    type        = string
    sensitive   = true
    description = "The Magalu Cloud key pair secret"
    default     = ""
}

variable "region" {
    type        = string
    description = "The Magalu Cloud region"
    default     = "br-se1"
}

