locals {
  vault_user_data = templatefile(
    var.user_supplied_userdata_path != null ? var.user_supplied_userdata_path : "${path.module}/templates/install_vault.sh.tpl",
    {
      key_vault_key_name    = var.key_vault_key_name
      key_vault_name        = var.key_vault_name
      key_vault_secret_id   = var.key_vault_secret_id
      leader_tls_servername = var.leader_tls_servername
      name                  = var.resource_name_prefix
      resource_group_name   = var.resource_group.name
      subscription_id       = var.subscription_id
      tenant_id             = var.tenant_id
      vault_version         = var.vault_version
      vm_scale_set_name     = var.vm_scale_set_name
    }
  )
}
