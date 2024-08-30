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

module "vnet" {
  source             = "./modules/vnet"
  vnet_name          = "vnet-${var.az_project_name}"
  vnet_address_space = [var.az_vn]
  vnet_rg_name       = azurerm_resource_group.rg.name
  vnet_rg_location   = azurerm_resource_group.rg.location
  vnet_tags          = var.deploy_tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.az_project_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = [var.az_subnetrange]
}

resource "azurerm_public_ip" "publicip" {
  #explicits add dependency to this resource but doesnt access any of that resources data in its arguments.
  depends_on = [
    module.vnet,
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
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "8080"]
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

  custom_data = filebase64("${path.module}/dependencies/apache.txt")
  tags        = var.deploy_tags

  # connection {
  #   type        = "ssh"
  #   host        = self.public_ip_address
  #   user        = self.admin_username
  #   private_key = file("~/.ssh/tf-tests")
  # }

  # provisioner "file" {
  #   source      = "./dependencies/apache.txt"
  #   destination = "/tmp/apache.txt"
  #   # on_failure = continue
  # }
  #
  # provisioner "remote-exec" {
  #   inline = ["sleep 120", "sudo cp /tmp/apache.txt /var/www/html/apache.txt"]
  # }

  provisioner "local-exec" {
    when        = destroy
    command     = "echo destroytime: `date` >> destroytime.txt"
    working_dir = "dependencies/"
  }
}

#terraform import azurerm_resource_group.import_rg -var-file=prod.tfvars /subscriptions/3d18c0a2-c84f-4be0-8a9f-fe22f2c61b32/resourceGroups/rg-test-import
resource "azurerm_resource_group" "import_rg" {
  name     = "rg-test-import"
  location = "eastus"
  tags = {
    "deployment" = "import"
  }
}

# generate inv for Ansible provisioning
resource "local_file" "inventory" {
  filename = "./inventory.yml"
  content  = <<EOF
[cfg]
${azurerm_public_ip.publicip["dev"].ip_address}
EOF
}
