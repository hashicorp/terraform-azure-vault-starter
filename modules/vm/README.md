# Azure VM Module

## Required Variables

* `identity_ids` - List of user assigned identities to apply to the VMs
* `instance_count` - Number of virtual machines to maintain in the scale set
* `resource_group` - Resource group in which resources will be deployed
* `resource_name_prefix` - Prefix placed before resource names
* `scale_set_name` - Name for virtual machine scale set
* `ssh_public_key` - Public key permitted to access the VM (as `azureuser` by default)
* `subnet_id` - Subnet in which the VMs will be deployed
* `user_data` - User data for virtual machine configuration

## Example Usage

```hcl
module "vm" {
  source = "./modules/vm"

  instance_count       = 5
  resource_name_prefix = "dev"
  scale_set_name       = "dev-vault"
  ssh_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADA..."
  subnet_id            = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/myvaultsubnetname"
  user_data            = base64encode("#!/bin/bash\necho 'starting setup'\n...")

  identity_ids = [
    "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-vault-vm",
  ]

  resource_group = {
    location = "eastus"
    name     = "myresourcegroupname"
  }
}
```
