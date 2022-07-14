/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

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
  description = "Prefix applied to resource names"
  type        = string

  # azurerm_key_vault name must not exceed 24 characters and has this as a prefix
  validation {
    condition     = length(var.resource_name_prefix) < 16 && (replace(var.resource_name_prefix, " ", "") == var.resource_name_prefix)
    error_message = "The resource_name_prefix value must be fewer than 16 characters and may not contain spaces."
  }
}

variable "shared_san" {
  default     = "vault.server.com"
  description = "This is a shared server name that the certs for all Vault nodes contain. This is the same value you will supply as input to the Vault installation module for the leader_tls_servername variable."
  type        = string
}

variable "vault_address_prefix" {
  default     = "10.0.1.0/24"
  description = "VM Virtual Network subnet address prefix"
  type        = string
}
