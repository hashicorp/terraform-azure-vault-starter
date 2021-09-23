provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vault" {
  location = var.location
  name     = "${var.resource_name_prefix}-vault"
  tags     = var.common_tags
}
