resource "azurerm_user_assigned_identity" "vault" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_key_vault_access_policy" "vault_msi" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.vault[0].principal_id
  tenant_id    = var.tenant_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_role_definition" "vault" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  name  = "${var.resource_name_prefix}-vault-server"
  scope = var.resource_group.id

  assignable_scopes = [
    var.resource_group.id,
  ]

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/*/read",
    ]
  }
}

resource "azurerm_role_assignment" "vault" {
  count = var.user_supplied_vm_identity_id != null ? 0 : 1

  principal_id       = azurerm_user_assigned_identity.vault[0].principal_id
  role_definition_id = azurerm_role_definition.vault[0].role_definition_resource_id
  scope              = var.resource_group.id
}

resource "azurerm_user_assigned_identity" "load_balancer" {
  count = var.user_supplied_lb_identity_id != null ? 0 : 1

  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-lb"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_key_vault_access_policy" "load_balancer_msi" {
  count = var.user_supplied_lb_identity_id != null ? 0 : 1

  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.load_balancer[0].principal_id
  tenant_id    = var.tenant_id

  secret_permissions = [
    "Get",
  ]
}
