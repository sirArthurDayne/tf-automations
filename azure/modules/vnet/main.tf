resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  resource_group_name = var.vnet_rg_name
  location            = var.vnet_rg_location
  tags                = var.vnet_tags
}
