data "openstack_networking_router_v2" "external" {
  name = "nrel"
}

data "openstack_networking_network_v2" "cluster_net" {
  name = var.cluster_net
}
