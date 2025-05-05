
resource "azapi_resource" "vm_public_ip" {
  type      = "Microsoft.Network/publicIPAddresses@2024-05-01"
  name      = "pip-${var.application_name}-${var.environment_name}"
  parent_id = azapi_resource.rg.id
  location  = azapi_resource.rg.location
  body = {
    properties = {
      publicIPAllocationMethod = "Static"
      publicIPAddressVersion   = "IPv4"
    }
    sku = {
      name = "Basic"
    }
  }
}
