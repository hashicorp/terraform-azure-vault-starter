/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "key_vault_id" {
  description = "Azure Key Vault containing the Vault key & secrets"
  type        = string
}

variable "resource_group" {
  description = "Azure resource group in which resources will be deployed"

  type = object({
    location = string
    name     = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "user_supplied_lb_identity_id" {
  default     = null
  description = "(Optional) User-provided User Assigned Identity for the Application Gateway. The minimum permissions must match the defaults generated by this module for TLS bundle retrieval."
  type        = string
}

variable "user_supplied_vm_identity_id" {
  default     = null
  description = "(Optional) User-provided User Assigned Identity for Vault servers. The minimum permissions must match the defaults generated by this module for cloud auto-join and auto-unseal."
  type        = string
}
