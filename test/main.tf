/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

terraform {
  cloud {
    organization = "hc-tfc-dev"

    workspaces {
      tags = [
        "integrationtest",
      ]
    }
  }

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }

    testingtoolsazure = {
      source  = "app.terraform.io/hc-tfc-dev/testingtoolsazure"
      version = "~> 0.2"
    }
  }
}

provider "azurerm" {
  features {}
}

module "quickstart" {
  source = "../examples/prereqs_quickstart"

  common_tags          = var.common_tags
  resource_group       = var.resource_group
  resource_name_prefix = var.resource_name_prefix
}

locals {
  lb_private_ip_address = cidrhost(module.quickstart.lb_address_prefix, 16)
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_key_vault_secret" "ssh_key" {
  name         = "${var.resource_name_prefix}-sshkey"
  value        = tls_private_key.ssh_key.private_key_pem
  key_vault_id = module.quickstart.key_vault_id
  tags         = var.common_tags
}
output "ssh_key_secret_id" {
  value = azurerm_key_vault_secret.ssh_key.id
}

module "vault" {
  source = "../"

  common_tags                          = var.common_tags
  key_vault_id                         = module.quickstart.key_vault_id
  key_vault_vm_tls_secret_id           = module.quickstart.key_vault_vm_tls_secret_id
  key_vault_ssl_cert_secret_id         = module.quickstart.key_vault_ssl_cert_secret_id
  lb_backend_ca_cert                   = module.quickstart.lb_backend_ca_cert
  leader_tls_servername                = module.quickstart.leader_tls_servername
  lb_private_ip_address                = local.lb_private_ip_address
  lb_subnet_id                         = module.quickstart.lb_subnet_id
  resource_group                       = module.quickstart.resource_group
  vault_subnet_id                      = module.quickstart.vault_subnet_id
  resource_name_prefix                 = var.resource_name_prefix
  vault_application_security_group_ids = module.quickstart.vault_application_security_group_ids
  ssh_public_key                       = tls_private_key.ssh_key.public_key_openssh
}

resource "testingtoolsazure_vmss_run_command" "wait_for_server_bootup" {
  count = 5

  instance_id         = tostring(count.index)
  resource_group_name = module.quickstart.resource_group.name
  scale_set_name      = module.vault.vm_scale_set_name

  scripts = [
    "date && while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done && date",
  ]
}

resource "testingtoolsazure_vmss_run_command" "bootstrap_vault" {
  instance_id         = 0
  resource_group_name = module.quickstart.resource_group.name
  scale_set_name      = module.vault.vm_scale_set_name

  scripts = [
    "VAULT_ADDR=\"https://127.0.0.1:8200\" VAULT_CACERT=\"/opt/vault/tls/vault-ca.pem\" VAULT_CLIENT_CERT=\"/opt/vault/tls/vault-cert.pem\" VAULT_CLIENT_KEY=\"/opt/vault/tls/vault-key.pem\" vault operator init",
  ]

  depends_on = [
    testingtoolsazure_vmss_run_command.wait_for_server_bootup,
  ]
}

locals {
  bootstrap_token = sensitive(regex("Initial Root Token: ([.a-zA-Z0-9]*)", testingtoolsazure_vmss_run_command.bootstrap_vault.message)[0])
}
