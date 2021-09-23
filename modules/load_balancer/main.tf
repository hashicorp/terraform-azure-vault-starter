locals {
  backend_address_pool_name      = "${var.resource_name_prefix}-vault"
  backend_http_setting_name      = "${var.resource_name_prefix}-vault"
  backend_trusted_cert_name      = "${var.resource_name_prefix}-vault-backend"
  frontend_ip_configuration_name = "${var.resource_name_prefix}-vault"
  frontend_port_name             = "${var.resource_name_prefix}-vault"
  http_listener_name             = "${var.resource_name_prefix}-vault"
  probe_name                     = "${var.resource_name_prefix}-vault"
  ssl_cert_name                  = "${var.resource_name_prefix}-vault"
}

resource "azurerm_public_ip" "vault_lb" {
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-lb-public"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.common_tags
}

resource "azurerm_application_gateway" "vault" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
  zones               = var.zones

  sku {
    capacity = var.sku_capacity
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }

  dynamic "autoscale_configuration" {
    for_each = var.sku_capacity == null ? [1] : [0]
    content {
      max_capacity = var.autoscale_max_capacity
      min_capacity = var.autoscale_min_capacity
    }
  }

  gateway_ip_configuration {
    name      = "${var.resource_name_prefix}-vault"
    subnet_id = var.subnet_id
  }

  identity {
    identity_ids = var.identity_ids
  }

  frontend_port {
    name = local.frontend_port_name
    port = 8200
  }

  # Unused (but mandatory) public IP config
  # https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq#how-do-i-use-application-gateway-v2-with-only-private-frontend-ip-address
  frontend_ip_configuration {
    name                 = "${var.resource_name_prefix}-vault-public"
    public_ip_address_id = azurerm_public_ip.vault_lb.id
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = var.private_ip_address == null ? "Dynamic" : "Static"
    subnet_id                     = var.subnet_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    cookie_based_affinity          = "Disabled"
    host_name                      = var.backend_server_name
    name                           = local.backend_http_setting_name
    port                           = 8200
    probe_name                     = local.probe_name
    protocol                       = "Https"
    request_timeout                = 60
    trusted_root_certificate_names = var.backend_ca_cert == null ? null : [local.backend_trusted_cert_name]
  }

  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    name                           = local.http_listener_name
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_cert_name
  }

  probe {
    host                = var.backend_server_name
    interval            = 30
    name                = local.probe_name
    path                = var.health_check_path
    protocol            = "Https"
    timeout             = 3
    unhealthy_threshold = 3
  }

  request_routing_rule {
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
    http_listener_name         = local.http_listener_name
    name                       = "${var.resource_name_prefix}-vault"
    rule_type                  = "Basic"
  }

  ssl_certificate {
    key_vault_secret_id = var.key_vault_ssl_cert_secret_id
    name                = local.ssl_cert_name
  }

  dynamic "trusted_root_certificate" {
    for_each = var.backend_ca_cert == null ? [0] : [1]
    content {
      data = var.backend_ca_cert
      name = local.backend_trusted_cert_name
    }
  }
}
