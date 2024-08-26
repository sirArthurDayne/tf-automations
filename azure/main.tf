resource "random_string" "rand_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg_prod" {
  name     = "rg-${var.az_enviroment}-${var.az_project_name}"
  location = var.az_region
  tags     = var.deploy_tags
}

resource "azurerm_virtual_network" "vnet_prod" {
  name                = "vn-${var.az_enviroment}-${var.az_project_name}"
  address_space       = [var.az_vn]
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = azurerm_resource_group.rg_prod.location
  tags                = var.deploy_tags
}


resource "azurerm_subnet" "subnet_prod" {
  name                 = "subnet-${var.az_enviroment}-${var.az_project_name}"
  resource_group_name  = azurerm_resource_group.rg_prod.name
  virtual_network_name = azurerm_virtual_network.vnet_prod.name
  address_prefixes     = ["172.16.50.0/24"]
}

resource "azurerm_public_ip" "publicip_prod" {
  #explicits add dependency to this resource but doesnt access any of that resources data in its arguments.
  depends_on = [
    azurerm_virtual_network.vnet_prod,
    azurerm_subnet.subnet_prod
  ]

  count               = 2
  name                = "publicip_prod-${count.index}"
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = azurerm_resource_group.rg_prod.location
  allocation_method   = "Static"
  tags                = var.deploy_tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.az_enviroment}"
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  security_rule {
    name                       = "allPort80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.deploy_tags
}
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_prod.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_network_interface" "nic_prod" {
  count               = 2
  name                = "nic_prod-${count.index}"
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = azurerm_resource_group.rg_prod.location
  ip_configuration {
    name                          = "internal_prod"
    subnet_id                     = azurerm_subnet.subnet_prod.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.publicip_prod[*].id, count.index)
  }
  tags = var.deploy_tags
}

data "azurerm_subscription" "current_subscription" {}

output "rg_dev_id" {
  description = "URL del grupo de recursos"
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current_subscription.tenant_id}/resource${azurerm_resource_group.rg_prod.id}"
}

output "publicIp" {
  description = "Ip publica de la vm"
  value       = azurerm_public_ip.publicip_prod[0].ip_address
}

output "privateIp" {
  description = "Ip privada de la vm"
  value       = azurerm_network_interface.nic_prod[0].private_ip_address
}
resource "azurerm_linux_virtual_machine" "linuxvm" {
  count               = 2
  name                = "vm-${var.az_enviroment}-${var.az_project_name}-${count.index}"
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = azurerm_resource_group.rg_prod.location
  size                = "Standard_B2s" #2cpus, 4GB ram
  computer_name       = "linuxvm${count.index}"
  admin_username      = "ubuntu"
  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.myssh_key
  }
  network_interface_ids = [element(azurerm_network_interface.nic_prod[*].id, count.index)]
  os_disk {
    name                 = "osdisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  #TODO: replace this with ansible
  # custom_data = filebase64("${path.module}/dependencies/apache.txt")

  tags = var.deploy_tags
}
