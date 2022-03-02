data "openstack_networking_network_v2" "cluster_net" {
  name           = var.cluster_net
}

data "openstack_networking_subnet_v2" "cluster_subnet" {

  name            = var.cluster_subnet
}
