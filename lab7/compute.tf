
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
