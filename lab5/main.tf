
resource "azurerm_resource_group" "main" {
  name     = "rg-terraform-101-${var.application_name}-${var.environment_name}"
  location = var.primary_location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.base_address_space]
}

locals {
  bastion_subnet_address_space = cidrsubnet(var.base_address_space, 6, 0)
  beta_subnet_address_space    = cidrsubnet(var.base_address_space, 4, 1)
  gamma_subnet_address_space   = cidrsubnet(var.base_address_space, 4, 2)
  delta_subnet_address_space   = cidrsubnet(var.base_address_space, 4, 3)
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.bastion_subnet_address_space]
}
resource "azurerm_subnet" "beta" {
  name                 = "snet-beta"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.beta_subnet_address_space]
}
resource "azurerm_subnet" "gamma" {
  name                 = "snet-gamma"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.gamma_subnet_address_space]
}
resource "azurerm_subnet" "delta" {
  name                 = "snet-delta"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.delta_subnet_address_space]
}

# resource "azurerm_network_security_group" "remote_access" {
#   name                = "nsg-${var.application_name}-${var.environment_name}-remote-access"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name

#   security_rule {
#     name                       = "ssh"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = chomp(data.http.my_ip.response_body)
#     destination_address_prefix = "*"
#   }
# }



# data "http" "my_ip" {
#   url = "https://api.ipify.org?format=text&ipv4=true"
# }

resource "azurerm_public_ip" "bastion" {
  name                = "pip-${var.application_name}-${var.environment_name}-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = "bas-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  # virtual_network_id  = azurerm_virtual_network.main.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
