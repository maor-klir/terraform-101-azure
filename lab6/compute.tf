
# resource "local_file" "private_key" {
#   content         = 
#   filename        = pathexpand("~/.ssh/vm1")
#   file_permission = "0600"
# }

# resource "local_file" "public_key" {
#   content  = tls_private_key.vm1.public_key_openssh
#   filename = pathexpand("~/.ssh/vm1.pub")
# }

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1-${var.application_name}-${var.environment_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm1.id,
  ]
  identity {
    type = "SystemAssigned"
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.vm1.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# resource "azurerm_virtual_machine_extension" "entra_id_login" {
#   name                       = "${azurerm_linux_virtual_machine.vm1.name}-AADSSHLoginForLinux"
#   virtual_machine_id         = azurerm_linux_virtual_machine.vm1.id
#   publisher                  = "Microsoft.Azure.ActiveDirectory"
#   type                       = "AADSSHLoginForLinux"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
# }

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "entra_id_user_login" {
  scope                = azurerm_linux_virtual_machine.vm1.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = azuread_group.remote_access_users.object_id
}
