# Azure User Data Module

## Required variables

* `key_vault_key_name` - Name of Key Vault Key used for unsealing Vault
* `key_vault_name` - Name of Key Vault in which the Vault key & secrets are stored
* `key_vault_secret_id` - ID of Key Vault Secret in which Vault TLS PFX bundle is stored
* `leader_tls_servername` - DNS name to use when checking certificate names of other Vault servers
* `resource_group` - Resource group in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `subscription_id` - ID of Azure subscription
* `tenant_id` - Tenant ID for Azure subscription in which resources are being deployed
* `vault_version` - Version of Vault to deploy
* `vm_scale_set_name` - Name of Virtual Machine Scale Set with which this user data will be deployed

## Example usage

```hcl
data "azurerm_client_config" "current" {}

module "user_data" {
  source = "./modules/user_data"

  key_vault_key_name    = "mykeyname"
  key_vault_name        = "mykeyvaultname"
  key_vault_secret_id   = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultsecretname/12ab12ab12ab12ab12ab12ab12ab12ab"
  leader_tls_servername = "vault.server.com"
  resource_name_prefix  = "dev"
  subscription_id       = data.azurerm_client_config.current.subscription_id
  tenant_id             = data.azurerm_client_config.current.tenant_id
  vault_version         = "1.8.1"
  vm_scale_set_name     = "dev-vault"

  resource_group = {
    name     = "myresourcegroupname"
  }
}
```
