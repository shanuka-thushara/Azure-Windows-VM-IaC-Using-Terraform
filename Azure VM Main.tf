resource "azurerm_resource_group" "RG" {
  name     = "Test-RG"
  location = "East US"
}

resource "azurerm_virtual_network" "VNET" {
  name                = "Test-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

