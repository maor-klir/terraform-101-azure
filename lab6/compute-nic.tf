
data "azurerm_subnet" "beta" {
  name                 = "snet-beta"
  virtual_network_name = "vnet-network-dev"
  resource_group_name  = "rg-terraform-101-network-dev"
}

resource "azurerm_network_interface" "vm1" {
  name                = "nic-${var.application_name}-${var.environment_name}-vm1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = data.azurerm_subnet.beta.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }
}
