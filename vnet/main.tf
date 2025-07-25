
resource "azurerm_resource_group" "ags-grp" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "ags-vnet" {
  name                = local.virtual_network.name
  address_space       = local.virtual_network.address_space
  resource_group_name = azurerm_resource_group.ags-grp.name
  location            = azurerm_resource_group.ags-grp.location
  depends_on          = [azurerm_resource_group.ags-grp]
}

resource "azurerm_subnet" "ags-subnet" {
  name                 = "ags-subnet"
  resource_group_name  = azurerm_resource_group.ags-grp.name
  virtual_network_name = azurerm_virtual_network.ags-vnet.name
  address_prefixes     = [local.address_subnet_prefixes[0]]
  # Ensure the subnet is created ater the virtual network
  depends_on = [azurerm_virtual_network.ags-vnet]
}
resource "azurerm_subnet" "ags-subnet-02" {
  name                 = "ags-subnet-02"
  resource_group_name  = azurerm_resource_group.ags-grp.name
  virtual_network_name = azurerm_virtual_network.ags-vnet.name
  address_prefixes     = [local.address_subnet_prefixes[1]]
  depends_on           = [azurerm_virtual_network.ags-vnet]
}

resource "azurerm_network_security_group" "ags-nsg" {
  name                = "ags-nsg"
  location            = azurerm_resource_group.ags-grp.location
  resource_group_name = azurerm_resource_group.ags-grp.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "ags-subnet-nsg" {
  subnet_id                 = azurerm_subnet.ags-subnet.id
  network_security_group_id = azurerm_network_security_group.ags-nsg.id
  depends_on                = [azurerm_subnet.ags-subnet, azurerm_network_security_group.ags-nsg]
}
resource "azurerm_subnet_network_security_group_association" "ags-subnet-02-nsg" {
  subnet_id                 = azurerm_subnet.ags-subnet-02.id
  network_security_group_id = azurerm_network_security_group.ags-nsg.id
  depends_on                = [azurerm_subnet.ags-subnet-02, azurerm_network_security_group.ags-nsg]
}

resource "azurerm_public_ip" "ags-pip" {
  name                = "ags-public-ip"
  location            = azurerm_resource_group.ags-grp.location
  resource_group_name = azurerm_resource_group.ags-grp.name
  allocation_method   = "Static"
}
resource "azurerm_public_ip" "ags-pip-02" {
  name                = "ags-public-ip-02"
  location            = azurerm_resource_group.ags-grp.location
  resource_group_name = azurerm_resource_group.ags-grp.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "ags-nic" {
  name                = "ags-nic"
  location            = azurerm_resource_group.ags-grp.location
  resource_group_name = azurerm_resource_group.ags-grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ags-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ags-pip.id
  }
  depends_on = [azurerm_subnet.ags-subnet, azurerm_public_ip.ags-pip]
}

resource "azurerm_network_interface" "ags-nic-02" {
  name                = "ags-nic-02"
  location            = azurerm_resource_group.ags-grp.location
  resource_group_name = azurerm_resource_group.ags-grp.name

  ip_configuration {
    name                          = "internal-02"
    subnet_id                     = azurerm_subnet.ags-subnet-02.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ags-pip-02.id
  }
  depends_on = [azurerm_subnet.ags-subnet-02, azurerm_public_ip.ags-pip]
}
resource "azurerm_linux_virtual_machine" "ags-vm" {
  name                = "ags-vm"
  resource_group_name = azurerm_resource_group.ags-grp.name
  location            = azurerm_resource_group.ags-grp.location
  size                = "Standard_D2alds_v6"
  admin_username      = local.addmin_username
  #admin_password      = "P@ssw0rd1234!"
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.addmin_username
    public_key = file("~/.ssh/id_rsa.pub") # Ensure you have your SSH key set up

  }
  user_data = base64encode(file("./cloud-init.sh")) # Optional: Use cloud-init for initial setup
  network_interface_ids = [
    azurerm_network_interface.ags-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "ags-windows-vm" {
  name                = "ags-windows-vm"
  resource_group_name = azurerm_resource_group.ags-grp.name
  location            = azurerm_resource_group.ags-grp.location
  size                = "Standard_D2alds_v6"
  admin_username      = local.addmin_username
  admin_password      = "P@ssw0rd1234!" # Ensure you use a secure password

  network_interface_ids = [
    azurerm_network_interface.ags-nic-02.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}
resource "azurerm_managed_disk" "ags-disk" {
  name                 = "ags-managed-disk"
  location             = azurerm_resource_group.ags-grp.location
  resource_group_name  = azurerm_resource_group.ags-grp.name
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 128
  create_option        = "Empty"
  depends_on           = [azurerm_linux_virtual_machine.ags-vm]
}
resource "azurerm_virtual_machine_data_disk_attachment" "ags-disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.ags-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.ags-vm.id
  lun                 = 0
  caching            = "ReadWrite"
}