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
