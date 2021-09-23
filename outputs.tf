output "vm_scale_set_name" {
  description = "Name of Virtual Machine Scale Set"
  value       = module.vm.vm_scale_set_name
}

output "vault_version" {
  description = "Vault version"
  value       = var.vault_version
}
