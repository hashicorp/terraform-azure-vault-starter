/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "location" {
  default     = "East US"
  description = "(Optional) The location/region to create the resource group (if one is not provided)"
  type        = string
}

variable "resource_group" {
  default     = null
  description = "(Optional) Azure resource group in which resources will be deployed; omit to create one"

  type = object({
    location = string
    name     = string
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

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}
