
data "openstack_networking_network_v2" "cluster_net" {
  name           = "iris-alaska-prod-internal"
}

data "openstack_networking_subnet_v2" "cluster_subnet" {
  name            = "iris-alaska-prod-internal"
}
