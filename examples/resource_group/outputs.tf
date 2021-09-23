output "resource_group" {
  value = {
    id       = azurerm_resource_group.vault.id
    location = azurerm_resource_group.vault.location
    name     = azurerm_resource_group.vault.name
  }
}
