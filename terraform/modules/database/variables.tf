variable "name" {
    type        = string
    description = "The name of the database instance"
}

variable "user" {
    type        = string
    description = "The username of the database instance"
}

variable "password" {
    type        = string
    description = "The password of the database instance"
}

variable "engine_name" {
    type        = string
    description = "The engine name of the database instance"
}

variable "engine_version" {
    type        = string
    description = "The engine version of the database instance"
} 

variable "instance_type" {
    type        = string
    description = "The instance type of the database instance"
}

variable "volume_size" {
    type        = number
    description = "The volume size of the database instance"
}

variable "volume_type" {
    type        = string
    description = "The volume type of the database instance"
}

variable "backup_retention_days" {
    type        = number
    description = "The backup retention days of the database instance"
    default = 0
    
}

variable "backup_start_at" {
    type        = string
    description = "The backup start at of the database instance"
    default = null
    nullable = true
}
