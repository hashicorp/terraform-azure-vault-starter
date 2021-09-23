# EXAMPLE: Create a Prerequisite Resource Group

An Azure [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) is required for resources deployed on Azure.

It can be easily defined as a single [Terraform resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group). It must exist before the prerequisite [Virtual Network](../vnet) & [TLS](../tls) resources, so an example of it is shown here.

## How to Use This Module

1. Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
2. Set any desired optional variables, e.g. `terraform.auto.tfvars`:
```
location = "East US"
```
3. Run `terraform init` and `terraform apply`

## Note

- Please note the following output produced by this Terraform module as this information will be required input for the Vault installation module:
  - `resource_group`
