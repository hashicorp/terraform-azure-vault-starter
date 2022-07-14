/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

provider "testingtoolsazure" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.quickstart.resource_group.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "${var.resource_name_prefix}-vault-test"
  resource_group_name  = module.quickstart.resource_group.name
  virtual_network_name = module.quickstart.virtual_network_name
  address_prefixes     = ["10.0.5.0/24"]
}
resource "azurerm_network_interface" "test" {
  location            = module.quickstart.resource_group.location
  name                = "${var.resource_name_prefix}-vault-test"
  resource_group_name = module.quickstart.resource_group.name
  tags                = var.common_tags

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }
}

resource "azurerm_user_assigned_identity" "test" {
  location            = module.quickstart.resource_group.location
  name                = "${var.resource_name_prefix}-test"
  resource_group_name = module.quickstart.resource_group.name
  tags                = var.common_tags
}
resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = module.quickstart.key_vault_id
  object_id    = azurerm_user_assigned_identity.test.principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_role_definition" "test" {
  name  = "${var.resource_name_prefix}-test"
  scope = local.resource_group_id

  assignable_scopes = [
    local.resource_group_id
  ]

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/*/read",
    ]
  }
}
resource "azurerm_role_assignment" "test" {
  principal_id       = azurerm_user_assigned_identity.test.principal_id
  role_definition_id = azurerm_role_definition.test.role_definition_resource_id
  scope              = local.resource_group_id
}

resource "azurerm_linux_virtual_machine_scale_set" "test" {
  admin_username      = "azureuser"
  instances           = 1
  location            = module.quickstart.resource_group.location
  name                = "${var.resource_name_prefix}-vault-test"
  overprovision       = false
  resource_group_name = module.quickstart.resource_group.name
  sku                 = "Standard_B1ms"
  tags                = var.common_tags
  zone_balance        = true

  user_data = base64encode(templatefile(
    "setup_vault_test_client.sh.tpl",
    {
      key_vault_secret_id   = module.quickstart.key_vault_vm_tls_secret_id
      lb_backend_ca_cert    = module.quickstart.lb_backend_ca_cert
      lb_private_ip_address = local.lb_private_ip_address
      leader_tls_servername = module.quickstart.leader_tls_servername
      vault_version         = module.vault.vault_version
    }
  ))

  zones = [
    "1",
    "2",
    "3",
  ]

  additional_capabilities {
    ultra_ssd_enabled = true
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  network_interface {
    name    = "${var.resource_name_prefix}-vault-test"
    primary = true

    ip_configuration {
      name      = "${var.resource_name_prefix}-vault-test"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_role_assignment.test,
  ]
}

resource "testingtoolsazure_vmss_run_command" "wait_for_test_system_bootup" {
  instance_id         = 0
  resource_group_name = module.quickstart.resource_group.name
  scale_set_name      = azurerm_linux_virtual_machine_scale_set.test.name

  scripts = [
    "date && while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done && date",
  ]
}

resource "time_sleep" "wait_30_seconds_after_vault_bootstrap" {
  create_duration = "30s"

  depends_on = [
    testingtoolsazure_vmss_run_command.bootstrap_vault,
    testingtoolsazure_vmss_run_command.wait_for_test_system_bootup,
  ]
}

resource "testingtoolsazure_vmss_run_command" "vault_operator_raft_list_peers" {
  instance_id         = 0
  resource_group_name = module.quickstart.resource_group.name
  scale_set_name      = azurerm_linux_virtual_machine_scale_set.test.name

  scripts = [
    "VAULT_ADDR=\"https://${module.quickstart.leader_tls_servername}:8200\" VAULT_TOKEN=\"${local.bootstrap_token}\" vault operator raft list-peers",
  ]

  depends_on = [
    time_sleep.wait_30_seconds_after_vault_bootstrap,
  ]
}

output "vault_operator_raft_list_peers" {
  value = regex("(?s)\\[stdout\\]\n\\s*(.*)\n\\[stderr\\]", testingtoolsazure_vmss_run_command.vault_operator_raft_list_peers.message)[0]
}
