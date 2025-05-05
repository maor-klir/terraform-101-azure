
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
  type                      = "Microsoft.KeyVault/vaults/secrets@2024-12-01-preview"
  name                      = "azapi-vm-ssh-private"
  parent_id                 = data.azapi_resource.keyvault.id
  schema_validation_enabled = false
  body = {
    properties = {
      value = tls_private_key.vm1.private_key_pem
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}

resource "azapi_resource" "vm1_ssh_public" {
  type                      = "Microsoft.KeyVault/vaults/secrets@2024-12-01-preview"
  name                      = "azapi-vm-ssh-public"
  parent_id                 = data.azapi_resource.keyvault.id
  schema_validation_enabled = false
  body = {
    properties = {
      value = tls_private_key.vm1.public_key_openssh
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}
