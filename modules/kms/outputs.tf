output "key_vault_key_name" {
  value = var.user_supplied_key_vault_key_name != null ? var.user_supplied_key_vault_key_name : azurerm_key_vault_key.vault[0].name
}
