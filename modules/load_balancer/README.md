# Azure Load Balancer Module

## Required Variables

* `backend_server_name` - DNS name to use when checking certificate names of other Vault servers
* `health_check_path` - HTTP path to use with Application Gateway health probe
* `identity_ids` - List of user assigned identities to apply to load balancer
* `key_vault_ssl_cert_secret_id` - Secret ID of Key Vault Certificate in which Vault PFX bundle is stored
* `resource_group` - Resource group in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `subnet_id` - Subnet in which the load balancer will be deployed

## Example Usage

```hcl
module "load_balancer" {
  source = "./modules/load_balancer"

  backend_server_name          = "vault.server.com"
  health_check_path            = "/v1/sys/health?activecode=200&standbycode=200&sealedcode=200&uninitcode=200"
  key_vault_ssl_cert_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/dev-vault-cert/12ab12ab12ab12ab12ab12ab12ab12ab"
  resource_name_prefix         = "dev"
  subnet_id                    = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/mylbsubnetname"

  identity_ids = [
    "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-vault-lb"
  ]

  resource_group = {
    location = "eastus"
    name     = "myresourcegroupname"
  }
}
```
