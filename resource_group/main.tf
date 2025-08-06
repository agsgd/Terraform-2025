resource "azurerm_resource_group" "function" {
  name     = "function-rg-${random_pet.group_name.id}"
  location = var.region
}

resource "random_pet" "group_name" {
  prefix = "stacks"

  length = 2
}
