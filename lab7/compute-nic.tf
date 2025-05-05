
data "azapi_resource" "network_rg" {
  name      = "rg-terraform-101-network-dev"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

data "azapi_resource" "vnet" {
  name      = "vnet-network-dev"
  parent_id = data.azapi_resource.network_rg.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
}

data "azapi_resource" "subnet_beta" {
  name      = "snet-beta"
  parent_id = data.azapi_resource.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  response_export_values = ["name"]
}

resource "azapi_resource" "vm1_nic" {
  type      = "Microsoft.Network/networkInterfaces@2024-05-01"
  name      = "nic-${var.application_name}-${var.environment_name}"
  location  = data.azapi_resource.network_rg.location
  parent_id = azapi_resource.rg.id
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
              id = data.azapi_resource.subnet_beta.id
            }
          }
        }
      ]
    }
  }
}
