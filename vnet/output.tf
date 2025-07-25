output "vnet_id" {
  value = azurerm_virtual_network.ags-vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.ags-vnet.name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.ags-vnet.address_space
}
output "public_ip_address" {
  value       = azurerm_public_ip.ags-pip.ip_address
  description = "The public IP address of the VM"
}
output "public_ip_address-02" {
  value       = azurerm_public_ip.ags-pip-02.ip_address
  description = "The public IP address of the VM"
}