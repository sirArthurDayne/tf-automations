resource "azurerm_resource_group" "rg_dev" {
    name = "rg-dev-blastwave-lab"
    location = var.az_region
}

resource "azurerm_virtual_network" "vn_dev" {
    name = "vn-dev-blastwave-lab"
    address_space = [var.az_vn]
    resource_group_name = azurerm_resource_group.rg_dev.name
    location = azurerm_resource_group.rg_dev.location
}
