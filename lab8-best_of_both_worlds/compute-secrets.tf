
# ED25519 key
resource "tls_private_key" "vm1" {
  algorithm = "ED25519"
}

data "azurerm_key_vault" "main" {
  name                = "kv-devops-dev-jx1pjc"
  resource_group_name = "rg-terraform-101-devops-dev"
}

resource "azurerm_key_vault_secret" "vm1_ssh_private_key" {
  name         = "azapi-vm-ssh-private"
  value        = tls_private_key.vm1.private_key_pem
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "vm1_ssh_public_key" {
  name         = "azapi-vm-ssh-public"
  value        = tls_private_key.vm1.public_key_openssh
  key_vault_id = data.azurerm_key_vault.main.id
}
