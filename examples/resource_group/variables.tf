variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "location" {
  default     = "East US"
  description = "Azure region for deployment"
  type        = string
}

variable "resource_name_prefix" {
  default     = "dev"
  description = "Prefix for resource names (e.g. \"prod\")"
  type        = string
}
