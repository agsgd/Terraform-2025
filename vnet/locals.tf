
locals {
  /*
  resource_group_name = "app-grp"
  location            = "central india"
  */

  virtual_network = {

    name          = "ags-vnet"
    address_space = ["10.12.0.0/16"]

  }

  address_subnet_prefixes = ["10.12.1.0/24", "10.12.2.0/24"]

  addmin_username = "azureuser"
  #addmin_password     = "P@ssw0rd1234!"

}
