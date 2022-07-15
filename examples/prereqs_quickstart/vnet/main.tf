/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vault" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags

  address_space = [
    var.address_space,
  ]
}

resource "azurerm_subnet" "vault" {
  name                 = "${var.resource_name_prefix}-vault"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vault.name

  address_prefixes = [
    var.vault_address_prefix,
  ]

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}

resource "azurerm_application_security_group" "vault" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_network_security_group" "vault" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_network_security_rule" "vault_internet_access" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Outbound"
  name                        = "${var.resource_name_prefix}-vault-access-to-internet"
  network_security_group_name = azurerm_network_security_group.vault.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "vault_internal_api" {
  access                      = "Allow"
  description                 = "Allow Vault nodes to reach other on port 8200 for API"
  destination_port_range      = "8200"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-vault-internal-api"
  network_security_group_name = azurerm_network_security_group.vault.name
  priority                    = 110
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.vault.id,
  ]

  source_application_security_group_ids = [
    azurerm_application_security_group.vault.id,
  ]
}

resource "azurerm_network_security_rule" "vault_internal_raft" {
  access                      = "Allow"
  description                 = "Allow Vault nodes to communicate on port 8201 for replication traffic, request forwarding, and Raft gossip"
  destination_port_range      = "8201"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-vault-internal-raft"
  network_security_group_name = azurerm_network_security_group.vault.name
  priority                    = 120
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.vault.id,
  ]

  source_application_security_group_ids = [
    azurerm_application_security_group.vault.id,
  ]
}

resource "azurerm_network_security_rule" "vault_lb_inbound" {
  access                      = "Allow"
  description                 = "Allow load balancer to reach Vault nodes on port 8200"
  destination_port_range      = "8200"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-vault-lb-inbound"
  network_security_group_name = azurerm_network_security_group.vault.name
  priority                    = 130
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = var.lb_address_prefix
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.vault.id,
  ]
}

resource "azurerm_network_security_rule" "vault_other_inbound" {
  access                      = "Deny"
  description                 = "Deny any non-matched traffic"
  destination_port_range      = "8200-8201"
  direction                   = "Inbound"
  name                        = "${var.resource_name_prefix}-vault-other-inbound"
  network_security_group_name = azurerm_network_security_group.vault.name
  priority                    = 200
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_application_security_group_ids = [
    azurerm_application_security_group.vault.id,
  ]
}

resource "azurerm_subnet_network_security_group_association" "vault" {
  network_security_group_id = azurerm_network_security_group.vault.id
  subnet_id                 = azurerm_subnet.vault.id

  depends_on = [
    azurerm_network_security_rule.vault_internet_access,
    azurerm_network_security_rule.vault_internal_api,
    azurerm_network_security_rule.vault_internal_raft,
    azurerm_network_security_rule.vault_lb_inbound,
    azurerm_network_security_rule.vault_other_inbound,
  ]
}

resource "azurerm_nat_gateway" "vault" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  sku_name            = "Standard"
  tags                = var.common_tags
}

resource "azurerm_public_ip" "vault_nat" {
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-nat"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "vault" {
  nat_gateway_id       = azurerm_nat_gateway.vault.id
  public_ip_address_id = azurerm_public_ip.vault_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vault" {
  nat_gateway_id = azurerm_nat_gateway_public_ip_association.vault.nat_gateway_id
  subnet_id      = azurerm_subnet.vault.id
}

resource "azurerm_subnet" "vault_lb" {
  name                 = "${var.resource_name_prefix}-vault-lb"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vault.name

  address_prefixes = [
    var.lb_address_prefix,
  ]

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}

# https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq#how-do-i-use-application-gateway-v2-with-only-private-frontend-ip-address
resource "azurerm_network_security_group" "vault_lb" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-lb"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_network_security_rule" "vault_lb_allow_gwm" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "65200-65535"
  direction                   = "Inbound"
  name                        = "Allow_GWM"
  network_security_group_name = azurerm_network_security_group.vault_lb.name
  priority                    = 100
  protocol                    = "*"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "GatewayManager"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "vault_lb_allow_alb" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "Allow_AzureLoadBalancer"
  network_security_group_name = azurerm_network_security_group.vault_lb.name
  priority                    = 110
  protocol                    = "*"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "vault_lb_deny_inbound_internet" {
  access                      = "Deny"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyAllInbound_Internet"
  network_security_group_name = azurerm_network_security_group.vault_lb.name
  priority                    = 4096
  protocol                    = "*"
  resource_group_name         = var.resource_group.name
  source_address_prefix       = "Internet"
  source_port_range           = "*"
}

resource "azurerm_subnet_network_security_group_association" "vault_lb" {
  subnet_id                 = azurerm_subnet.vault_lb.id
  network_security_group_id = azurerm_network_security_group.vault_lb.id

  depends_on = [
    azurerm_network_security_rule.vault_lb_allow_gwm,
    azurerm_network_security_rule.vault_lb_allow_alb,
    azurerm_network_security_rule.vault_lb_deny_inbound_internet,
  ]
}

# Azure Bastion Service is not required for Vault operation, but it
# provides an secure and easy to use way access to the Vault VMs
resource "azurerm_public_ip" "abs" {
  count = var.abs_address_prefix == null ? 0 : 1

  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-abs"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_subnet" "vault_abs" {
  count = var.abs_address_prefix == null ? 0 : 1

  address_prefixes     = [var.abs_address_prefix] # at least /27 or larger
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.vault.name
}

resource "azurerm_bastion_host" "main" {
  count = var.abs_address_prefix == null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-abs"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags

  ip_configuration {
    name                 = "${var.resource_name_prefix}-vault-abs"
    public_ip_address_id = azurerm_public_ip.abs[0].id
    subnet_id            = azurerm_subnet.vault_abs[0].id
  }
}
