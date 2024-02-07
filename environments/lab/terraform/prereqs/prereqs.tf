# Contains lab-specific infra which should be set up first

terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

resource "openstack_networking_network_v2" "storage" {
  name           = "lab-storage"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "storage" {
  network_id = openstack_networking_network_v2.storage.id
  cidr       = "192.168.102.0/24"
  name           = "lab-storage"
  no_gateway = true
}

resource "openstack_networking_network_v2" "compute" {
  name           = "lab-compute"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "compute" {
  network_id = openstack_networking_network_v2.compute.id
  name           = "lab-compute"
  cidr       = "192.168.101.0/24"
  no_gateway = true
}
