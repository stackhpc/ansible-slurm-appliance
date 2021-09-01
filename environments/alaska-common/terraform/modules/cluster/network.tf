
data "openstack_networking_network_v2" "cluster_net" {
  name = var.cluster_net
}

data "openstack_networking_subnet_v2" "cluster_subnet" {
  name = var.cluster_subnet
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
  fixed_ip = [for n in openstack_compute_instance_v2.login[each.key].network: n if n.name == var.cluster_net][0].fixed_ip_v4
}

data "openstack_networking_port_v2" "slurmctl" {
  name = var.slurmctl_port
  network_id = data.openstack_networking_network_v2.cluster_net.id
}

// data "openstack_networking_network_v2" "rdma_net" {
//   name = var.rdma_net
// }

// resource "openstack_networking_port_v2" "rdma" {
  
//   for_each = toset(concat(keys(var.login_nodes), keys(var.compute_nodes)))

//   name = "${var.cluster_name}-${each.key}"
//   network_id = data.openstack_networking_network_v2.rdma_net.id
//   admin_state_up = "true"

//   binding {
//     vnic_type = "direct"
//   }

// }