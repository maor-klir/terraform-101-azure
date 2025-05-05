
data "azurerm_subnet" "beta" {
  name                 = "snet-beta"
  virtual_network_name = "vnet-network-dev"
  resource_group_name  = "rg-terraform-101-network-dev"
}

resource "azapi_resource" "vm1_nic" {
  type      = "Microsoft.Network/networkInterfaces@2024-05-01"
  name      = "nic-${var.application_name}-${var.environment_name}"
  location  = azurerm_resource_group.main.location
  parent_id = azurerm_resource_group.main.id
  body = {
    properties = {
      ipConfigurations = [
        {
          name = "public"
          properties = {
            privateIPAllocationMethod = "Dynamic"
            publicIPAddress = {
              id = azapi_resource.vm_public_ip.id
            }
            subnet = {
              id = data.azurerm_subnet.beta.id
            }
          }
        }
      ]
    }
  }
}
