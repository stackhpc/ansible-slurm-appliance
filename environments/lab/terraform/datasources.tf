data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

data "openstack_networking_network_v2" "storage" {
  name = var.storage_network
}

data "openstack_networking_network_v2" "cluster" {
  name = var.cluster_network
}

data "openstack_networking_network_v2" "control" {
  name = var.control_network
}

data "openstack_networking_subnet_v2" "storage" {
  name = var.storage_subnet
}

data "openstack_networking_subnet_v2" "cluster" {
  name = var.cluster_subnet
}

data "openstack_networking_subnet_v2" "control" {
  name = var.control_subnet
}

data "openstack_networking_secgroup_v2" "grafana" {
  name = "grafana"
}

data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}
