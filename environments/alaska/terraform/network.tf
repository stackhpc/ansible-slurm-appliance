
data "openstack_networking_network_v2" "cluster_net" {
  name           = "iris-alaska-prod-internal"
}

data "openstack_networking_subnet_v2" "cluster_subnet" {
  name            = "iris-alaska-prod-internal"
}

data "openstack_networking_network_v2" "external" {
  name = "CUDN-Internet"
}

data "openstack_networking_floatingip_v2" "logins" {

  for_each = var.login_nodes

  address = each.value.address
}

resource "openstack_compute_floatingip_associate_v2" "logins" {
  for_each = var.login_nodes

  floating_ip = each.value.address
  instance_id = openstack_compute_instance_v2.login[each.key].id
   # for multi-rail nodes need to control which network's ports are used for FIP:
  fixed_ip = [for n in openstack_compute_instance_v2.login[each.key].network: n if n.name == "iris-alaska-prod-internal"][0].fixed_ip_v4
}
