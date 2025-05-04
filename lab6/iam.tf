
data "azuread_client_config" "current" {}

resource "azuread_group" "remote_access_users" {
  display_name     = "${var.application_name}-${var.environment_name}-remote-access-users"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "remote_access_user_membership" {
  count            = length(var.remote_access_users)
  group_object_id  = azuread_group.remote_access_users.object_id
  member_object_id = data.azuread_user.remote_access_users[count.index].object_id
}

data "azuread_user" "remote_access_users" {
  count               = length(var.remote_access_users)
  user_principal_name = var.remote_access_users[count.index]
}
