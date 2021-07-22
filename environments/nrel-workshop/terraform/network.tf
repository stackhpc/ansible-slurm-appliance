
data "openstack_networking_network_v2" "cluster_net" {
  name           = "nrel"
}

data "openstack_networking_subnet_v2" "cluster_subnet" {
  name            = "nrel"
}
