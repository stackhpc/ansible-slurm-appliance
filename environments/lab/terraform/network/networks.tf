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
  cidr       = "192.168.102.0/24"
  name           = "nrel-storage"
  no_gateway = true
}

resource "openstack_networking_network_v2" "compute" {
  name           = "nrel-compute"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "compute" {
  network_id = openstack_networking_network_v2.compute.id
  name           = "nrel-compute"
  cidr       = "192.168.101.0/24"
  no_gateway = true
}

resource "openstack_networking_network_v2" "control" {
  name           = "nrel-control"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "control" {
  network_id = openstack_networking_network_v2.control.id
  cidr       = "192.168.100.0/24"
  name           = "nrel-control"
}

resource "openstack_networking_secgroup_v2" "deploy_ssh" {
  name        = "deploy_ssh"
  description = "Permit ssh from deployhost (not in same project)"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "deploy_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "10.0.1.130/16"
  security_group_id = openstack_networking_secgroup_v2.deploy_ssh.id
}
