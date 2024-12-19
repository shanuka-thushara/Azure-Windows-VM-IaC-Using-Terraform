# Variables
variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "Test-RG"
}

variable "location" {
  description = "The location of the resources"
  default     = "East US"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  default     = "Tf@$$w0rd1234!"
  sensitive   = true
}

# Create a Azure Resource Group
resource "azurerm_resource_group" "RG" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "Test"
  }
}

# Create a Azure Virtual Network
resource "azurerm_virtual_network" "VNET" {
  name                = "Test-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  tags = {
    environment = "Test"
  }
}

# Create a Subnet 
resource "azurerm_subnet" "AzureSubnet" {
  name                 = "AzureSubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a NIC 
resource "azurerm_network_interface" "nic" {
  name                = "Test-nic"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.AzureSubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Test"
  }
}

# Create a Public IP
resource "azurerm_public_ip" "PIP" {
  name                = "Public-IP"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"

  tags = {
    environment = "Test"
  }
}

# Create a Network Security Group 
resource "azurerm_network_security_group" "NSG" {
  name                = "Test-NSG"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  tags = {
    environment = "Test"
  }
}

# Create a Azure Virtual Machine
resource "azurerm_windows_virtual_machine" "VM" {
  name                = "Test-VM"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = "Test"
  }
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.RG.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.VNET.name
}

output "subnet_name" {
  value = azurerm_subnet.AzureSubnet.name
}

output "public_ip" {
  value = azurerm_public_ip.PIP.ip_address
}

output "virtual_machine_id" {
  value = azurerm_windows_virtual_machine.VM.id
}