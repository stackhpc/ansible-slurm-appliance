data "openstack_networking_network_v2" "cluster_net" {
  name           = var.cluster_net
}

data "openstack_networking_subnet_v2" "cluster_subnet" {

  name            = var.cluster_subnet
}

resource "openstack_networking_port_v2" "rdma" {
  
  for_each = toset(concat(keys(var.login_nodes), keys(var.compute_nodes)))

  name = "${var.cluster_name}-${each.key}"
  network_id = data.openstack_networking_network_v2.cluster_net.id
  admin_state_up = "true"

  binding {
    vnic_type = "direct"
  }

}
