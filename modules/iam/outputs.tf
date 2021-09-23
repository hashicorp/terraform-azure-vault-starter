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
