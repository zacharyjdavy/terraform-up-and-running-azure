provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "zdavy-sandbox" {
  name = "zdavy-sandbox-resource-group"
  location = "Central US"

  tags = {
    environment = "zdavy-sandbox"
  }
}

resource "azurerm_virtual_network" "zdavy-sandbox" {
  name = "zdavy-sandbox-virtual-network"
  location = "centralus"
  address_space = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.zdavy-sandbox.name

  tags = {
    environment = "zdavy-sandbox"
  }
}

resource "azurerm_subnet" "zdavy-sandbox" {
  name = "zdavy-sandbox-subnet"
  resource_group_name = azurerm_resource_group.zdavy-sandbox.name
  virtual_network_name = azurerm_virtual_network.zdavy-sandbox.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "zdavy-sandbox" {
  name = "zdavy-sandbox-network-interface"
  location = azurerm_resource_group.zdavy-sandbox.location
  resource_group_name = azurerm_resource_group.zdavy-sandbox.name

  ip_configuration {
    name = "zdavy-sandbox-ip-configuration"
    subnet_id = azurerm_subnet.zdavy-sandbox.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "zdavy-sandbox"
  }
}

resource "tls_private_key" "zdavy-sandbox" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "zdavy-sandbox" {
  content = tls_private_key.zdavy-sandbox.private_key_pem
  filename = "${path.module}/.ssh/id_rsa"
  directory_permission = "700"
  file_permission = "600"
}

resource "azurerm_linux_virtual_machine" "zdavy-sandbox" {
  name = "zdavy-sandbox-linux-virtual-machine"
  location = azurerm_resource_group.zdavy-sandbox.location
  resource_group_name = azurerm_resource_group.zdavy-sandbox.name
  admin_username = "zd058510"
  size = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.zdavy-sandbox.id
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer = "UbuntuServer"
    publisher = "Canonical"
    sku = "18.04-LTS"
    version = "latest"
  }


  admin_ssh_key {
    username = "zd058510"
    public_key = tls_private_key.zdavy-sandbox.public_key_openssh
  }

  tags = {
    environment = "zdavy-sandbox"
  }
}