# EXAMPLE: Create a Prerequisite Private Virtual Network

## About This Example

In order to deploy the Vault module, a preconfigured Virtual Network must first be deployed. This module contains all the necessary resources to set up the Virtual Network.

## Network Design for Vault

* The Virtual Network should be deployed in a location with [Availablity Zones](https://azure.microsoft.com/en-us/global-infrastructure/geographies/)
* The Vault VM Virtual Network subnet requires outbound access (necessary for downloading Vault)
* The internal load balancer Virtual Network subnet should have external internet traffic blocked via Network Security Group rules

## How to Use This Module

1. Ensure Azure credentials are [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) (e.g. `az login` and `az account set --subscription="SUBSCRIPTION_ID"` on your workstation)
2. Set the required (and optional as desired) variables, e.g. `terraform.auto.tfvars`:
```
resource_group = {
  location = "East US"
  name     = "My Resource Group Name"
}
```
3. Run `terraform init` and `terraform apply`

## Required Variables

* `resource_group` - [Azure Resource Group](../resource_group) in which resources will be deployed

## Note

- Please note the following output produced by this Terraform module as this information will be required input for the Vault installation module:
  - `vault_application_security_group_ids`
  - `lb_subnet_id`
  - `vault_subnet_id`
