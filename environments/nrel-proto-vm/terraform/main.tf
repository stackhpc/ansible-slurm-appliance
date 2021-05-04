terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "compute_names" {
    type = list(string)
    default = ["compute-0", "compute-1"]
    description = "A list of hostnames for the compute nodes (will be prefixed by cluster_name)"
}

variable "login_names" {
  type = list(string)
  default = ["login-0", "login-1"]
  description = "A list of hostnames for the login nodes (will be prefixed by cluster_name)"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_network" {
    type = string
    description = "Name of network to use for cluster"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "login_flavor" {
    type = string
    description = "Name of instance flavor for login node(s)"
}

variable "login_image" {
    type = string
    description = "Name of image for login node(s)"
}

variable "control_flavor" {
    type = string
    description = "Name of instance flavor for control node"
}

variable "control_image" {
    type = string
    description = "Name of image for compute node"
}

variable "compute_flavor" {
    type = string
    description = "Name of instance flavor for compute node(s)"
}

variable "compute_image" {
    type = string
    description = "Name of image for compute node(s)"
}

variable "cidr" {
    type = string
    default = "192.168.42.0/24"
    description = "Range in CIDR notation for cluster subnet"
}

variable "external_network" {
  type = string
  description = "Name of pre-existing external network"
}

variable "external_router" {
  type = string
  description = "Name of pre-existing router on external network"
}

variable "provider_networks" {
  type = list(string)
  description = "Name of pre-existing networks to additionally connect to cluster instances"
  default = []
}

data "openstack_networking_network_v2" "external_network" {
  name = var.external_network
}

data "openstack_networking_network_v2" "provider_networks" {
  for_each = toset(var.provider_networks)

  name = each.key
}

resource "openstack_networking_network_v2" "cluster" {
    name           = var.cluster_name
    description = "Network for openhpc cluster ${var.cluster_name}"
    admin_state_up = "true"
    segments {
      network_type = "vlan"
    }
}

resource "openstack_networking_subnet_v2" "cluster" {
    name            = var.cluster_name
    network_id      = openstack_networking_network_v2.cluster.id
    cidr            = var.cidr
    ip_version      = 4
}

resource "openstack_networking_port_v2" "control" {
  name = "${var.cluster_name}-control"
  network_id = openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  binding {
    vnic_type = "direct"
    profile = jsonencode({capabilities = ["switchdev"]})
  }
}

resource "openstack_compute_instance_v2" "control" {
  name = "${var.cluster_name}-control"
  image_name = var.control_image
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.control.id
  }

  dynamic "network" { # TODO update?
    for_each = data.openstack_networking_network_v2.provider_networks
  
    content {
      uuid = network.value["id"]
    }
  }

}

resource "openstack_networking_port_v2" "logins" {

  for_each = toset(var.login_names)

  name = each.value
  network_id = openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  binding {
    vnic_type = "direct"
    profile = jsonencode({capabilities = ["switchdev"]})
  }
}


resource "openstack_compute_instance_v2" "logins" {

  for_each = toset(var.login_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair

  network {
    port = openstack_networking_port_v2.logins[each.value].id
  }

  dynamic "network" { # TODO update?
    for_each = data.openstack_networking_network_v2.provider_networks
  
    content {
      uuid = network.value["id"]
    }
  }

}

resource "openstack_networking_port_v2" "computes" {
  
  for_each = toset(var.compute_names)

  name = each.value
  network_id = openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  binding {
    vnic_type = "direct"
    profile = jsonencode({capabilities = ["switchdev"]})
  }
}


resource "openstack_compute_instance_v2" "compute" {

  for_each = toset(var.compute_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.compute_image
  flavor_name = var.compute_flavor
  key_pair = var.key_pair

  network {
    port = openstack_networking_port_v2.computes[each.value].id
  }

  dynamic "network" {# TODO: update?
    for_each = data.openstack_networking_network_v2.provider_networks
  
    content {
      uuid = network.value["id"]
    }
  }

}

data "openstack_networking_router_v2" "external" {
  name = var.external_router
}

resource "openstack_networking_router_interface_v2" "cluster" {
  router_id = data.openstack_networking_router_v2.external.id
  subnet_id = openstack_networking_subnet_v2.cluster.id
}

resource "openstack_networking_floatingip_v2" "logins" {

  for_each = toset(var.login_names)

  pool = data.openstack_networking_network_v2.external_network.name
}

resource "openstack_compute_floatingip_associate_v2" "logins" {
  for_each = toset(var.login_names)

  floating_ip = openstack_networking_floatingip_v2.logins[each.key].address
  instance_id = openstack_compute_instance_v2.logins[each.key].id
}

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "control": openstack_compute_instance_v2.control,
                            "logins": openstack_compute_instance_v2.logins,
                            "computes": openstack_compute_instance_v2.compute,
                            # "fip": openstack_networking_floatingip_v2.login
                          },
                          )
  filename = "../inventory/hosts"
}