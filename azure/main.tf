resource "random_string" "rand_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.az_project_name}"
  location = var.az_region
  tags     = var.deploy_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vn-${var.az_project_name}"
  address_space       = [var.az_vn]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.deploy_tags
}


resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.az_project_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.az_subnetrange]
}

resource "azurerm_public_ip" "publicip" {
  #explicits add dependency to this resource but doesnt access any of that resources data in its arguments.
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet
  ]
  # count               = 2
  for_each            = var.az_enviroment
  name                = "publicip-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags                = var.deploy_tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.az_project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_network_interface" "nic" {
  # count               = 2
  for_each            = var.az_enviroment
  name                = "nic-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "internal_${each.key}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = element(azurerm_public_ip.publicip_prod[*].id, count.index)
    public_ip_address_id = azurerm_public_ip.publicip[each.key].id
  }
  tags = var.deploy_tags
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  # count               = 2
  # name                = "vm-${var.az_enviroment}-${var.az_project_name}-${count.index}"
  for_each            = var.az_enviroment
  name                = "vm-${var.az_project_name}-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" #1cpus, 4GB ram
  computer_name       = "lx-${each.key}"
  admin_username      = "ubuntu"
  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.myssh_key
  }
  # network_interface_ids = [element(azurerm_network_interface.nic_prod[*].id, count.index)]
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  os_disk {
    name                 = "osdisk${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.deploy_tags
}

data "azurerm_subscription" "current_subscription" {}

output "rg_URL" {
  description = "URL del grupo de recursos"
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current_subscription.tenant_id}/resource${azurerm_resource_group.rg.id}"
}

# iterador y objeto: salida
# output "publicIP_two_input" {
#   description = "String de conexion SSH por ambiente"
#   value = [for env, ip in azurerm_public_ip.publicip: "[${env}]: ssh ubuntu@${ip.ip_address}" ]
# }

# mapear salida a un map
output "sshconn" {
  description = "String de conexion SSH por ambiente"
  value = {for env, ip in azurerm_public_ip.publicip: env => "ssh ubuntu@${ip.ip_address}" }
  sensitive = true
}

# show only keys
output "sshconnKeys" {
  description = "Show map keys only"
  value = keys({for env, ip in azurerm_public_ip.publicip: env => "ssh ubuntu@${ip.ip_address}" })
}

#show only values
output "sshconnValues" {
  description = "Show map values only"
  value = values({for env, ip in azurerm_public_ip.publicip: env => "ssh ubuntu@${ip.ip_address}" })
}

