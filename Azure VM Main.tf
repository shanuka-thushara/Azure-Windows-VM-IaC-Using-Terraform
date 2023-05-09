# Create a Azure Resource Group
resource "azurerm_resource_group" "RG" {
  name     = "Test-RG"
  location = "East US"
}

# Create a Azure Virtual Network
resource "azurerm_virtual_network" "VNET" {
  name                = "Test-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
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
}

# Create a Public IP
resource "azurerm_public_ip" "PIP" {
  name                = "Public-IP"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
  }

# Create a Network Security Group 
resource "azurerm_network_security_group" "NSG" {
  name                = "Test-NSG"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

# Create a Azure Virtual Machine
resource "azurerm_windows_virtual_machine" "VM" {
  name                = "Test-VM"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_B2ms"
  admin_username      = "azureadmin"
  admin_password      = "Tf@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

# Create a OS disk
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
}
