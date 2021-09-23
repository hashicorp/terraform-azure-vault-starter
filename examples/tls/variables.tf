variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
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
  description = "Prefix applied to resource names"
  type        = string

  # azurerm_key_vault name must not exceed 24 characters and has this as a prefix
  validation {
    condition     = length(var.resource_name_prefix) < 16 && (replace(var.resource_name_prefix, " ", "") == var.resource_name_prefix)
    error_message = "The resource_name_prefix value must be fewer than 16 characters and may not contain spaces."
  }
}
