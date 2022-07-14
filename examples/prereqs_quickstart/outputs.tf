/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "key_vault_id" {
  value = module.tls.key_vault_id
}

output "key_vault_ssl_cert_secret_id" {
  value = module.tls.key_vault_ssl_cert_secret_id
}

output "key_vault_vm_tls_secret_id" {
  value = module.tls.key_vault_vm_tls_secret_id
}

output "lb_address_prefix" {
  value = module.vnet.lb_address_prefix
}

output "lb_subnet_id" {
  value = module.vnet.lb_subnet_id
}

output "leader_tls_servername" {
  value = module.tls.shared_san
}

output "lb_backend_ca_cert" {
  value = module.tls.root_ca_pem
}

output "resource_group" {
  value = local.resource_group
}

output "vault_application_security_group_ids" {
  value = module.vnet.vault_application_security_group_ids
}

output "vault_subnet_id" {
  value = module.vnet.vault_subnet_id
}

output "virtual_network_name" {
  value = module.vnet.virtual_network_name
}
