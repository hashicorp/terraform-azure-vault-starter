## Overview

This test directory defines basic integration tests for the module.

## Prereqs

* Terraform or tfenv in PATH
* [Terraform Cloud credentials](https://www.terraform.io/cli/commands/login)
* Azure credentials
  * For local development, use the [Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

## Use

```
go test -v -timeout 120m
```

Optional environment variables:
  * `DEPLOY_ENV` - set this to change the prefix applied to resource names.
  * `TEST_DONT_DESTROY_UPON_SUCCESS` - set this to skip running terraform destroy upon testing success
  * `TEST_RESOURCE_GROUP_LOCATION` & `TEST_RESOURCE_GROUP_NAME` - set these to provide an existing Resource Group for resources

The `go test` will populate terraform `.auto.tfvars` in each module directory and execute `terraform apply` sequentially through them. If all deploys & tests pass, each module will be destroyed in reverse order.

### Cleaning Up

If resources aren't deleted automatically (at the end of successful tests), Terraform can be manually invoked to delete them (`terraform destroy`)
