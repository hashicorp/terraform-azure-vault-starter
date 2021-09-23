# Azure KMS Module

## Required variables

* `key_vault_id` - ID of Key Vault in which the Vault unseal key will be created
* `resource_name_prefix` - Prefix placed before resource names

## Example usage

```hcl
module "kms" {
  source = "./modules/kms"

  key_vault_id         = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/..."
  resource_name_prefix = "dev"
}
```
