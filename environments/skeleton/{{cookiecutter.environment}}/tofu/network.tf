
data "openstack_networking_network_v2" "cluster_networks" {
  for_each = {for n in var.cluster_networks: n.network => n}

  name           = each.value.network
}

data "openstack_networking_subnet_v2" "cluster_subnets" {
  for_each = {for n in var.cluster_networks: n.network => n}

  name            = each.value.subnet
}

data "openstack_networking_secgroup_v2" "login" {
  for_each = toset(var.login_security_groups)

  name = each.key
}

data "openstack_networking_secgroup_v2" "nonlogin" {
  for_each = toset(var.nonlogin_security_groups)

  name = each.key
}
