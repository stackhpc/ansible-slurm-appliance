terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}


resource "openstack_networking_network_v2" "storage" {
  name           = "nrel-storage"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "storage" {
  network_id = openstack_networking_network_v2.storage.id
  cidr       = "192.168.100.0/24"
  name           = "nrel-storage"
}

resource "openstack_networking_network_v2" "compute" {
  name           = "nrel-compute"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "control" {
  network_id = openstack_networking_network_v2.compute.id
  name           = "nrel-compute"
  cidr       = "192.168.101.0/24"
}
