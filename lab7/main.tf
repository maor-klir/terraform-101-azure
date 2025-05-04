
resource "azapi_resource" "rg" {
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
  name      = "rg-terraform-101-${var.application_name}-${var.environment_name}"
  location  = var.primary_location
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
}

data "azapi_client_config" "current" {}

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

resource "tls_private_key" "vm1" {
  algorithm = "ED25519"
}

data "azapi_resource" "devops_rg" {
  name      = "rg-terraform-101-devops-dev"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}

data "azapi_resource" "keyvault" {
  name      = "kv-devops-dev-jx1pjc"
  parent_id = data.azapi_resource.devops_rg.id
  type      = "Microsoft.KeyVault/vaults@2024-12-01-preview"
}

resource "azapi_resource" "vm1_ssh_private" {
  type      = "Microsoft.KeyVault/vaults/secrets@2024-12-01-preview"
  name      = "azapi-vm-ssh-private"
  parent_id = data.azapi_resource.keyvault.id
  body = {
    properties = {
      value = tls_private_key.vm1.private_key_pem
    }
  }
}

resource "azapi_resource" "vm1_ssh_public" {
  type      = "Microsoft.KeyVault/vaults/secrets@2024-12-01-preview"
  name      = "azapi-vm-ssh-public"
  parent_id = data.azapi_resource.keyvault.id
  body = {
    properties = {
      value = tls_private_key.vm1.public_key_openssh
    }
  }
}

locals {
  admin_username = "nakniki"
  computername   = "vm1-${var.application_name}${var.environment_name}"
}

resource "azapi_resource" "vm1" {
  type      = "Microsoft.Compute/virtualMachines@2024-07-01"
  name      = "vm1-${var.application_name}-${var.environment_name}"
  parent_id = azapi_resource.rg.id
  location  = azapi_resource.rg.location

  body = {
    properties = {
      osProfile = {
        computerName  = "vm1-${var.application_name}-${var.environment_name}"
        adminUsername = "nakniki"
        linuxConfiguration = {
          ssh = {
            publicKeys = [
              {
                keyData = tls_private_key.vm1.public_key_openssh
                path    = "/home/${local.admin_username}/.ssh/authorized_keys"
              }
            ]
          }
        }
      }
      storageProfile = {
        imageReference = {
          offer     = "ubuntu-24_04-lts"
          publisher = "Canonical"
          sku       = "server"
          version   = "latest"
        }
        osDisk = {
          createOption = "FromImage"
          caching      = "ReadWrite"
          managedDisk = {
            storageAccountType = "Standard_LRS "
          }
        }
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.vm1_nic.id

          }
        ]
      }
      hardwareProfile = {
        vmSize = "Standard_B1s"
      }

    }
  }
}
