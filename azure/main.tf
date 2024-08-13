resource "azurerm_resource_group" "rg_dev" {
    name = "rg-${var.az_enviroment}-${var.az_project_name}"
    location = var.az_region
}

resource "azurerm_virtual_network" "vn_dev" {
    name = "vn-${var.az_enviroment}-${var.az_project_name}"
    address_space = [var.az_vn]
    resource_group_name = azurerm_resource_group.rg_dev.name
    location = azurerm_resource_group.rg_dev.location
}
