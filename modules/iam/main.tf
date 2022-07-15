/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

data "azurerm_subscription" "current" {}

locals {
  resource_group_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group.name}"
}

resource "azurerm_user_assigned_identity" "vault" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_key_vault_access_policy" "vault_msi" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.vault[0].principal_id
  tenant_id    = var.tenant_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_role_definition" "vault" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  name  = "${var.resource_name_prefix}-vault-server"
  scope = local.resource_group_id

  assignable_scopes = [
    local.resource_group_id,
  ]

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/*/read",
    ]
  }
}

resource "azurerm_role_assignment" "vault" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  principal_id       = azurerm_user_assigned_identity.vault[0].principal_id
  role_definition_id = azurerm_role_definition.vault[0].role_definition_resource_id
  scope              = local.resource_group_id
}

resource "azurerm_user_assigned_identity" "load_balancer" {
  count = var.user_supplied_lb_identity_id != null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-lb"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_key_vault_access_policy" "load_balancer_msi" {
  count = var.user_supplied_lb_identity_id != null ? 0 : 1

  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.load_balancer[0].principal_id
  tenant_id    = var.tenant_id

  secret_permissions = [
    "Get",
  ]
}
