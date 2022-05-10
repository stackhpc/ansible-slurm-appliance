
data "openstack_networking_network_v2" "cluster_net" {
  name           = var.cluster_net
}

data "openstack_networking_subnet_v2" "cluster_subnet" {

  name            = var.cluster_subnet
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}

data "openstack_networking_secgroup_v2" "ssh" {
  name = "SSH"
}

data "openstack_networking_secgroup_v2" "https" {
  name = "HTTPS"
}
