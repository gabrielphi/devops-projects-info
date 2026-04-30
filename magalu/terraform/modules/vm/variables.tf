variable "instances" {
    type = map(object({
        name                = string
        machine_type        = string
        image               = string
        allocate_public_ipv4 = optional(bool, true)
    }))
    description = "Map of virtual machine instances to create. Key is used as instance identifier."
    default     = {}
}