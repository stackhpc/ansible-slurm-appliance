
data "openstack_networking_network_v2" "networks" {
  for_each = {for n in var.networks: n.network => n}

  name           = each.value.network
}

data "openstack_networking_subnet_v2" "subnets" {
  for_each = {for n in var.networks: n.network => n}

  name            = each.value.subnet
}
