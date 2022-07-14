/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "lb_address_prefix" {
  value = azurerm_subnet.vault_lb.address_prefixes[0]
}

output "lb_subnet_id" {
  value = azurerm_subnet_network_security_group_association.vault_lb.id
}

output "vault_application_security_group_ids" {
  value = [azurerm_application_security_group.vault.id]
}

output "vault_lb_network_security_group_name" {
  value = azurerm_network_security_group.vault_lb.name
}

output "vault_network_security_group_name" {
  value = azurerm_network_security_group.vault.name
}

output "vault_subnet_id" {
  value = azurerm_subnet_network_security_group_association.vault.id

  depends_on = [
    azurerm_subnet_nat_gateway_association.vault,
  ]
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vault.name

  depends_on = [
    azurerm_subnet_network_security_group_association.vault,
    azurerm_subnet_network_security_group_association.vault_lb,
  ]
}
