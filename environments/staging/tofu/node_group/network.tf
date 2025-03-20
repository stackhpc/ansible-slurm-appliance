
data "openstack_networking_network_v2" "network" {

  for_each = {for net in var.networks: net.network => net}

  name = each.value.network
}

data "openstack_networking_subnet_v2" "subnet" {

  for_each = {for net in var.networks: net.network => net}

  name = each.value.subnet
}
