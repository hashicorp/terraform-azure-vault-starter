/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "vault" {
  count = var.resource_group == null ? 1 : 0

  location = var.location
  name     = "${var.resource_name_prefix}-vault"
  tags     = var.common_tags
}

locals {
  resource_group = var.resource_group == null ? { location = azurerm_resource_group.vault[0].location, name = azurerm_resource_group.vault[0].name } : var.resource_group
}

module "vnet" {
  source = "./vnet"

  abs_address_prefix   = var.abs_address_prefix
  address_space        = var.address_space
  common_tags          = var.common_tags
  lb_address_prefix    = var.lb_address_prefix
  resource_group       = local.resource_group
  resource_name_prefix = var.resource_name_prefix
  vault_address_prefix = var.vault_address_prefix
}

module "tls" {
  source = "./tls"

  common_tags          = var.common_tags
  resource_group       = local.resource_group
  resource_name_prefix = var.resource_name_prefix
  shared_san           = var.shared_san
}
