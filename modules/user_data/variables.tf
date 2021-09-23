variable "key_vault_name" {
  description = "Azure Key Vault in which the Vault key & secrets are stored"
  type        = string
}

variable "key_vault_key_name" {
  description = "Key vault key for auto-unseal"
  type        = string
}

variable "key_vault_secret_id" {
  type        = string
  description = "Key Vault Secret containing the PFX bundle for TLS"
}

variable "leader_tls_servername" {
  type        = string
  description = "One of the DNS Subject Alternative Names on the cert in key_vault_secret_id"
}

variable "resource_group" {
  description = "Azure resource group in which resources will be deployed"

  type = object({
    name = string
  })
}

variable "resource_name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "user_supplied_userdata_path" {
  default     = null
  description = "File path to custom VM configuration (i.e. cloud-init config) being supplied by the user"
  type        = string
}

variable "vault_version" {
  description = "Vault version"
  type        = string
}

variable "vm_scale_set_name" {
  description = "Name for virtual machine scale set"
  type        = string
}
