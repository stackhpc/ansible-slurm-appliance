
data "openstack_networking_network_v2" "network" {

  for_each = { for net in var.networks : net.network => net }

  name = each.value.network
}

data "openstack_networking_subnet_v2" "subnet" {

  for_each = { for net in var.networks : net.network => net }

  name = each.value.subnet
}

resource "openstack_networking_port_v2" "trunk-parent" {
  for_each = var.use_trunk ? toset(var.nodes) : []
  name = "${split(".", local.fqdns[each.key])[0]}-trunk-parent"
  network_id = var.trunk_parent_network_id
  lifecycle {
    ignore_changes = [extra_dhcp_option]
  }
}

resource "openstack_networking_port_v2" "trunk-subport" {
  for_each = var.use_trunk ? toset(var.nodes) : []
  name = "${split(".", local.fqdns[each.key])[0]}-trunk-subport"
  network_id = var.trunk_subport_network_id
  lifecycle {
    ignore_changes = [extra_dhcp_option]
  }
}

resource "openstack_networking_trunk_v2" "trunk" {
  for_each = var.use_trunk ? toset(var.nodes) : []
  name = "${split(".", local.fqdns[each.key])[0]}-trunk"
  admin_state_up = "true"
  port_id        = openstack_networking_port_v2.trunk-parent[each.key].id

  sub_port {
    port_id           = openstack_networking_port_v2.trunk-subport[each.key].id
    segmentation_id   = var.trunk_subport_vlan_id
    segmentation_type = "vlan"
  }
}
