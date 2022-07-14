/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "lb_identity_id" {
  value = var.user_supplied_lb_identity_id != null ? var.user_supplied_lb_identity_id : azurerm_user_assigned_identity.load_balancer[0].id

  depends_on = [
    azurerm_key_vault_access_policy.load_balancer_msi,
  ]
}

output "vm_identity_id" {
  value = var.user_supplied_vm_identity_id != null ? var.user_supplied_vm_identity_id : azurerm_user_assigned_identity.vault[0].id

  depends_on = [
    azurerm_key_vault_access_policy.vault_msi,
    azurerm_role_assignment.vault,
  ]
}
