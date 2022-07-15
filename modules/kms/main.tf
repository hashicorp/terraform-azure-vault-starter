/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "azurerm_key_vault_key" "vault" {
  count = var.user_supplied_key_vault_key_name != null ? 0 : 1

  key_size     = 2048
  key_type     = "RSA"
  key_vault_id = var.key_vault_id
  name         = "${var.resource_name_prefix}-vault-key"
  tags         = var.common_tags

  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]
}
