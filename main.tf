/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

data "azurerm_client_config" "current" {}

locals {
  vm_scale_set_name = "${var.resource_name_prefix}-vault"
}

module "kms" {
  source = "./modules/kms"

  common_tags                      = var.common_tags
  key_vault_id                     = var.key_vault_id
  resource_name_prefix             = var.resource_name_prefix
  user_supplied_key_vault_key_name = var.user_supplied_key_vault_key_name
}

module "iam" {
  source = "./modules/iam"

  common_tags                  = var.common_tags
  key_vault_id                 = var.key_vault_id
  resource_group               = var.resource_group
  resource_name_prefix         = var.resource_name_prefix
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  user_supplied_lb_identity_id = var.user_supplied_lb_identity_id
  user_supplied_vm_identity_id = var.user_supplied_vm_identity_id
}

module "user_data" {
  source = "./modules/user_data"

  key_vault_key_name          = module.kms.key_vault_key_name
  key_vault_name              = element(split("/", var.key_vault_id), length(split("/", var.key_vault_id)) - 1)
  key_vault_secret_id         = var.key_vault_vm_tls_secret_id
  leader_tls_servername       = var.leader_tls_servername
  resource_group              = var.resource_group
  subscription_id             = data.azurerm_client_config.current.subscription_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  user_supplied_userdata_path = var.user_supplied_userdata_path
  vault_version               = var.vault_version
  vm_scale_set_name           = local.vm_scale_set_name
}

module "load_balancer" {
  source = "./modules/load_balancer"

  autoscale_max_capacity       = var.lb_autoscale_max_capacity
  autoscale_min_capacity       = var.lb_autoscale_min_capacity
  backend_ca_cert              = var.lb_backend_ca_cert
  backend_server_name          = var.leader_tls_servername
  common_tags                  = var.common_tags
  health_check_path            = var.health_check_path
  key_vault_ssl_cert_secret_id = var.key_vault_ssl_cert_secret_id
  private_ip_address           = var.lb_private_ip_address
  resource_group               = var.resource_group
  resource_name_prefix         = var.resource_name_prefix
  sku_capacity                 = var.lb_sku_capacity
  subnet_id                    = var.lb_subnet_id
  zones                        = var.zones

  identity_ids = [
    module.iam.lb_identity_id,
  ]
}

module "vm" {
  source = "./modules/vm"

  application_security_group_ids = var.vault_application_security_group_ids
  common_tags                    = var.common_tags
  health_check_path              = var.health_check_path
  instance_count                 = var.instance_count
  instance_type                  = var.instance_type
  resource_group                 = var.resource_group
  resource_name_prefix           = var.resource_name_prefix
  user_supplied_source_image_id  = var.user_supplied_source_image_id
  scale_set_name                 = local.vm_scale_set_name
  ssh_public_key                 = var.ssh_public_key
  subnet_id                      = var.vault_subnet_id
  ultra_ssd_enabled              = var.ultra_ssd_enabled
  user_data                      = module.user_data.vault_userdata_base64_encoded
  zones                          = var.zones

  backend_address_pool_ids = [
    module.load_balancer.backend_address_pool_id,
  ]

  identity_ids = [
    module.iam.vm_identity_id,
  ]
}
