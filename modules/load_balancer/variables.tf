/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "autoscale_max_capacity" {
  default     = null
  description = "(Optional) Autoscaling capacity unit cap for Application Gateway"
  type        = number
}

variable "autoscale_min_capacity" {
  default     = 0
  description = "Autoscaling minimum capacity units for Application Gateway (ignored if sku_capacity is provided)"
  type        = number
}

variable "backend_ca_cert" {
  default     = null
  type        = string
  description = "(Optional) PEM cert of Certificate Authority to use when verifying health probe SSL traffic"
}

variable "backend_server_name" {
  type        = string
  description = "Hostname to use for backend http setting and health checks"
}

variable "common_tags" {
  default     = {}
  description = "(Optional) Map of common tags for all taggable resources"
  type        = map(string)
}

variable "health_check_path" {
  description = "The endpoint to check for Vault's health status"
  type        = string
}

variable "identity_ids" {
  description = "User assigned identities to apply to load balancer"
  type        = list(string)
}

variable "key_vault_ssl_cert_secret_id" {
  description = "Key Vault Certificate for listener certificate"
  type        = string
}

variable "private_ip_address" {
  default     = null
  description = "(Optional) Load balancer fixed IPv4 address"
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

variable "sku_capacity" {
  default     = null
  description = "(Optional) Fixed (non-autoscaling) number of capacity units for Application Gateway (overrides autoscale_min_capacity/autoscale_max_capacity variables)"
  type        = number
}

variable "subnet_id" {
  description = "Subnet where load balancer will be deployed"
  type        = string
}

variable "zones" {
  default     = null
  description = "Azure availability zones in which to deploy the Application Gateway"
  type        = list(string)
}
