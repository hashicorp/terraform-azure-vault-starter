/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "key_vault_key_name" {
  value = var.user_supplied_key_vault_key_name != null ? var.user_supplied_key_vault_key_name : azurerm_key_vault_key.vault[0].name
}
