
locals {
  # Map node names to trunk parent port IP addresses from var.ip_addresses by node index
  trunk_parent_ips = {
    for idx, n in var.nodes :
    n => try(var.ip_addresses[var.trunk_parent_network_id][idx], null)
  }
  # Map "<node>-<subport index>" keys to trunk subport IP addresses from var.ip_addresses
  trunk_subport_ips = {
    for pair in var.use_trunk ? setproduct(var.nodes, range(length(var.trunk_subport_network_ids))) : [] :
    "${pair[0]}-${pair[1]}" => try(var.ip_addresses[var.trunk_subport_network_ids[pair[1]]][index(var.nodes, pair[0])], null)
  }
}

data "openstack_networking_network_v2" "network" {

  for_each = { for net in var.networks : net.network => net }

  name = each.value.network
}

data "openstack_networking_subnet_v2" "subnet" {

  for_each = { for net in var.networks : net.network => net }

  name = each.value.subnet
}

resource "openstack_networking_port_v2" "trunk_parent" {
  for_each = var.use_trunk ? toset(var.nodes) : []
  name = "${split(".", local.fqdns[each.key])[0]}-trunk-parent"
  network_id = var.trunk_parent_network_id
  dynamic "fixed_ip" {
    for_each = local.trunk_parent_ips[each.key] != null ? [local.trunk_parent_ips[each.key]] : []
    content {
      ip_address = fixed_ip.value
    }
  }
  lifecycle {
    ignore_changes = [extra_dhcp_option]
  }
}

resource "openstack_networking_port_v2" "trunk_subport" {
  for_each = {
    for pair in var.use_trunk ? setproduct(var.nodes, range(length(var.trunk_subport_network_ids))) : [] :
    "${pair[0]}-${pair[1]}" => pair
  }
  name       = "${split(".", local.fqdns[each.value[0]])[0]}-trunk-subport-${each.value[1]}"
  network_id = var.trunk_subport_network_ids[each.value[1]]
  dynamic "fixed_ip" {
    for_each = local.trunk_subport_ips[each.key] != null ? [local.trunk_subport_ips[each.key]] : []
    content {
      ip_address = fixed_ip.value
    }
  }
  lifecycle {
    ignore_changes = [extra_dhcp_option]
  }
}

resource "openstack_networking_trunk_v2" "trunk" {
  for_each = var.use_trunk ? toset(var.nodes) : []
  name = "${split(".", local.fqdns[each.key])[0]}-trunk"
  admin_state_up = "true"
  port_id        = openstack_networking_port_v2.trunk_parent[each.key].id

  dynamic "sub_port" {
    for_each = range(var.use_trunk ? length(var.trunk_subport_network_ids) : 0)
    content {
      port_id           = openstack_networking_port_v2.trunk_subport["${each.key}-${sub_port.value}"].id
      segmentation_id   = var.trunk_subport_vlan_ids[sub_port.value]
      segmentation_type = "vlan"
    }
  }
}
