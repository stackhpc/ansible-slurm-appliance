
data "openstack_networking_network_v2" "cluster_net" {
  name           = "WCDC-iLab-60"
}

data "openstack_networking_subnet_v2" "cluster_subnet" {
  name            = "WCDC-iLab-60"
}
