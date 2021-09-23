variable "abs_address_prefix" {
  default     = "10.0.3.0/24"
  description = "Azure Bastion Service Virtual Network subnet address prefix (set to \"\" to disable ABS creation)"
  type        = string
}

variable "address_space" {
  default     = "10.0.0.0/16"
  description = "Virtual Network address space"
  type        = string
}

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "lb_address_prefix" {
  default     = "10.0.2.0/24"
  description = "Load balancer Virtual Network subnet address prefix"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group in which resources will be deployed"

  type = object({
    name     = string
    location = string
  })
}

variable "resource_name_prefix" {
  default     = "dev"
  description = "Prefix for resource names (e.g. \"prod\")"
  type        = string
}

variable "vault_address_prefix" {
  default     = "10.0.1.0/24"
  description = "VM Virtual Network subnet address prefix"
  type        = string
}
