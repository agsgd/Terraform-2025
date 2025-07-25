resource "azurerm_resource_group" "kv-grp" {
  name     = "kv-grp"
  location = "east us"
}


resource "azurerm_key_vault" "kv-terraform" {
  name                = "kvexample20202025"
  location            = azurerm_resource_group.kv-grp.location
  resource_group_name = azurerm_resource_group.kv-grp.name
  sku_name            = "standard"
  tenant_id          = "e52a8cfb-1b98-4921-9991-da9c97316d5f"
  purge_protection_enabled = true
  soft_delete_retention_days = 7
}