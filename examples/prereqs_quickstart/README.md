# EXAMPLE: Prerequisite Configuration (Virtual Network and Secrets)

## About This Example

In order to deploy the Vault module, you must have a Virtual Network that meets the requirements [listed in the main README](../../README.md#how-to-use-this-module) along with TLS certs that can be used with the Vault nodes and load balancer. If you do not already have these resources, you can use the code provided in this directory to provision them. 

## How to Use This Module

1. Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
2. Set the required (and optional as desired) variables, e.g. `terraform.auto.tfvars`:
```
resource_name_prefix = "dev"
```
3. Run `terraform init` and `terraform apply`

## Required variables

* `resource_name_prefix` - string value to use as base for resource names (e.g. `dev`)

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
