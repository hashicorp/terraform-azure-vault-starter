# Vault Azure Module

This is a Terraform module for provisioning Vault with [integrated storage](https://www.vaultproject.io/docs/concepts/integrated-storage) on Azure. This module defaults to setting up a cluster with 5 Vault nodes (as recommended by the [Vault with Integrated Storage Reference Architecture](https://learn.hashicorp.com/vault/operations/raft-reference-architecture)).

## About This Module

This module implements the [Vault with Integrated Storage Reference Architecture](https://learn.hashicorp.com/vault/operations/raft-reference-architecture#node) on Azure using the open source version of Vault 1.8+.

## How to Use This Module

- Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
    - Owner role or equivalent is required (to create the Azure role for Vault servers)

- Ensure pre-requisite resources are created:
    - [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group)
        - See this [Resource Group module](https://github.com/hashicorp/terraform-azure-vault-starter/tree/main/examples/resource_group) for an example implementation
    - [Virtual Network Subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) (one for Vault Virtual Machines, and another for an Application Gateway load balancer) and associated [Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)/[Application Security Group](https://docs.microsoft.com/en-us/azure/virtual-network/application-security-groups)
        - See this [Virtual Network module](https://github.com/hashicorp/terraform-azure-vault-starter/tree/main/examples/vnet) for an example implementation
    - [Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) with a [PFX Certificate bundle](https://docs.microsoft.com/en-us/azure/key-vault/certificates/certificate-scenarios)
        - See this [TLS module](https://github.com/hashicorp/terraform-azure-vault-starter/tree/main/examples/tls) for an example implementation with supporting commands (PowerShell or openssl) to create the certificates

- Create a Terraform configuration that pulls in this module and specifies values for the required variables:

```hcl
provider "azurerm" {
  features {
    virtual_machine_scale_set {
      # This can be enabled to sequentially replace instances when
      # application configuration updates (e.g. changed user_data)
      # are made
      roll_instances_when_required = false
    }
  }
}

module "vault" {
  source  = "hashicorp/vault-starter/azure"
  version = "0.1.0"

  # (Required when cert in 'key_vault_vm_tls_secret_id' is signed by a private CA) Certificate authority cert (PEM)
  lb_backend_ca_cert = file("./cacert.pem")

  # IP address (in Vault subnet) for Vault load balancer
  # (example value here is fine to use alongside the default values in the example vnet module)
  lb_private_ip_address = "10.0.2.253"

  # Virtual Network subnet for Vault load balancer
  lb_subnet_id = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/mylbsubnetname"

  # One of the DNS Subject Alternative Names on the cert in key_vault_vm_tls_secret_id
  leader_tls_servername = "vault.server.com"

  # Virtual Network subnet for Vault VMs
  vault_subnet_id = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/mysubnetname"

  # Key Vault (containing Vault TLS bundle in Key Vault Certificate and Key Vault Secret form)
  key_vault_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/..."

  # Key Vault Certificate containing TLS certificate for load balancer
  key_vault_ssl_cert_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/dev-vault-cert/12ab12ab12ab12ab12ab12ab12ab12ab"

  # Key Vault Secret containing TLS certificate for Vault VMs
  key_vault_vm_tls_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultsecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

  # Resource group object in which resources will be deployed
  resource_group = {
    id       = "/subscriptions/.../resourceGroups/myresourcegroupname"
    location = "eastus"
    name     = "myresourcegroupname"
  }

  # Prefix for resource names
  resource_name_prefix = "dev"

  # SSH public key (for authentication to Vault servers)
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADA..."

  # Application Security Group IDs for Vault VMs
  vault_application_security_group_ids = ["/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/applicationSecurityGroups/mysecuritygroupname"]
}
```

- Run `terraform init` and `terraform apply`

- You must [initialize](https://www.vaultproject.io/docs/commands/operator/init#operator-init) your Vault cluster after you create it. Begin by SSHing into your Vault cluster.
    - The [example Virtual Network module](https://github.com/hashicorp/terraform-azure-vault-starter/tree/main/examples/vnet) deploys (optionally but enabled by default) the [Azure Bastion Service](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) to allow this via the Azure Portal.

- To initialize the Vault cluster, run the following commands:

```bash
vault operator init
```

- This should return back the following output which includes the recovery keys and initial root token (omitted here):

```
...
Success! Vault is initialized
```

- Please securely store the recovery keys and initial root token that Vault returns to you.
- To check the status of your Vault cluster, export your Vault token and run the [list-peers](https://www.vaultproject.io/docs/commands/operator/raft#list-peers) command:

```bash
export VAULT_TOKEN="<your Vault token>"
vault operator raft list-peers
```

- Please note that Vault does not enable [dead server cleanup](https://www.vaultproject.io/docs/concepts/integrated-storage/autopilot#dead-server-cleanup) by default. You must enable this to avoid manually managing the Raft configuration every time there is a change in the Vault ASG. To enable dead server cleanup, run the following command:

 ```bash
vault operator raft autopilot set-config \
    -cleanup-dead-servers=true \
    -dead-server-last-contact-threshold=10 \
    -min-quorum=3
 ```

- You can verify these settings after you apply them by running the following command:

```bash
vault operator raft autopilot get-config
```

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-azure-vault-starter/tree/main/LICENSE) for more details.
