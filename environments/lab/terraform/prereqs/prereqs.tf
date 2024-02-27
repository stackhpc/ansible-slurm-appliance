# Contains lab-specific infra which should be set up first

terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

locals {
  cluster_name = regex("cluster_name  = \"([a-z]+)\"", file("${path.module}/../terraform.tfvars"))[0]
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

resource "openstack_blockstorage_volume_v3" "state" {
  # read cluster_name from main tfvars file:
  name = "${local.cluster_name}-state"
  description = "State for control node"
  size = 10 # GB, doesn't matter for lab
}
