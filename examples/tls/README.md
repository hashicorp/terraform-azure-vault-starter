# EXAMPLE: TLS Configuration on Load Balancer and Vault Nodes

## About This Example

The Vault installation module requires you to secure the load balancer that it creates with an HTTPS listener. It also requires TLS certificates on all of the Vault nodes in the cluster. If you do not already have a Key Vault and existing TLS certs that you can use for these requirements, you can use the example code in this directory to create them and upload them to an [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/).

NOTE: These are example certs valid for a very short period of time (30 days) - *at an absolute minimum*, these expiration dates will need to be adjusted before using them in production. You are advised to implement/use an appropriate TLS management strategy for your organization. 

## How to Use This Module

1. Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
2. Set the required (and optional as desired) variables, e.g. `terraform.auto.tfvars`:
```
resource_group = {
  location = "East US"
  name = "My Resource Group Name"
}
```
3. Place a signed certificate PFX bundle in a file named `certificate-to-import.pfx`.
    - On Windows, this can be generated via the `.\scripts\gen_tls.ps1` PowerShell command (may need to be preceeded by `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` to bypass "file ... is not digitally " errors)
    - On macOS or Linux, this can be generated via the `./scripts/gen_tls.sh` command
4. Run `terraform init` and `terraform apply`

### Security Notes

#### Terraform State

The [Terraform State](https://www.terraform.io/docs/language/state/index.html) produced by this code has sensitive data (cert private keys) stored in it.

Please secure your Terraform state using the [recommendations listed here](https://www.terraform.io/docs/language/state/sensitive-data.html#recommendations).

#### Key Vault Firewall

The Key Vault can optionally be [configured to retrict access to specified IP addresses and networks](https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs#how-integration-works); this is an additional layer of security (it doesn't replace Access Policies, just supplements them).

On the Key Vault resource:
```
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["<MY_IP_ADDRESS_HERE>/32"]

    virtual_network_subnet_ids = [
      azurerm_subnet_network_security_group_association.vault.id,
      azurerm_subnet_network_security_group_association.vault_lb.id,
    ]
  }
```

## Required Variables

* `resource_group` - [Azure Resource Group](../resource_group) in which resources will be deployed

## Note

- Please note the following output produced by this Terraform module as this information will be required input for the Vault installation module:
  - `key_vault_id`
  - `key_vault_ssl_cert_secret_id`
  - `key_vault_vm_tls_secret_id`
- The `SHARED_SAN` environment variable used in certificate generation (example above is `vault.server.com`) will be needed for the `leader_tls_servername` variable
- The contents of the `rootca.pem` file will be needed for the `lb_backend_ca_cert` variable
