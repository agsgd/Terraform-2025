variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
 
}

variable "location" {
  description = "The location of the resources"
  type        = string
 
}
/*
variable "virtual_network" {
  description = "The virtual network configuration"
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "address_subnet_prefixes" {
  description = "The address prefixes for the subnets"
  type        = list(string)
}
*/