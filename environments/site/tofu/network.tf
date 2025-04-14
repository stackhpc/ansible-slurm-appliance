
data "openstack_networking_network_v2" "cluster_net" {

  for_each = {for net in var.cluster_networks: net.network => net}

  name = each.value.network
}

data "openstack_networking_subnet_v2" "cluster_subnet" {

  for_each = {for net in var.cluster_networks: net.network => net}

  name = each.value.subnet
}

data "openstack_identity_auth_scope_v3" "scope" {
  # This is an arbitrary name which is only used as a unique identifier so an
  # actual token isn't used as the ID.
  name = "scope"
}

data "openstack_networking_secgroup_v2" "login" {
  for_each = toset(var.login_security_groups)

  name = each.key
  tenant_id = data.openstack_identity_auth_scope_v3.scope.project_id
}

data "openstack_networking_secgroup_v2" "nonlogin" {
  for_each = toset(var.nonlogin_security_groups)

  name = each.key
  tenant_id = data.openstack_identity_auth_scope_v3.scope.project_id
}
