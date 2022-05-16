
data "openstack_networking_network_v2" "cluster_net" {
  name           = var.cluster_net
}

data "openstack_networking_subnet_v2" "cluster_subnet" {

  name            = var.cluster_subnet
}

data "openstack_networking_secgroup_v2" "login" {
  for_each = toset(var.login_security_groups)

  name = each.key
}

data "openstack_networking_secgroup_v2" "nonlogin" {
  for_each = toset(var.nonlogin_security_groups)

  name = each.key
}
