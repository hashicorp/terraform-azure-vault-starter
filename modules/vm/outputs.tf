output "vm_scale_set_name" {
  description = "Name of Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vault_cluster.name
}
