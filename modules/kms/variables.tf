/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "common_tags" {
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "key_vault_id" {
  description = "Azure Key Vault in which the Vault seal secret will be stored"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}

variable "user_supplied_key_vault_key_name" {
  default     = null
  description = "(Optional) User-provided Key Vault Key name. Providing this will disable the generation of a Key Vault Key used for Vault auto-unseal"
  type        = string
}
