/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "vm_scale_set_name" {
  description = "Name of Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vault_cluster.name
}
