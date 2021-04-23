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
  default = ["login-0"]
  description = "A list of hostnames for the login nodes (will be prefixed by cluster_name)"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_network" {
    type = string
    description = "Name of (preexisting) network to use for cluster"
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

variable "login_availability_zone" {
    type = string
    description = "Availability zone to use for login node(s)"
    default = null
}

variable "control_flavor" {
    type = string
    description = "Name of instance flavor for control node"
}

variable "control_image" {
    type = string
    description = "Name of image for compute node"
}

variable "control_availability_zone" {
    type = string
    description = "Availability zone to use for control node(s)"
    default = null
}

variable "compute_flavor" {
    type = string
    description = "Name of instance flavor for compute node(s)"
}

variable "compute_image" {
    type = string
    description = "Name of image for compute node(s)"
}

variable "compute_availability_zone" {
    type = string
    description = "Availability zone to use for compute node(s)"
    default = null
}

data "openstack_networking_network_v2" "cluster" {
  name = var.cluster_network
}

resource "openstack_compute_instance_v2" "control" {
  name = "${var.cluster_name}-control"
  image_name = var.control_image
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  availability_zone = var.control_availability_zone
  
  network {
    uuid = data.openstack_networking_network_v2.cluster.id
  }

  timeouts {
    create = "60m"
    delete = "20m"
  }

}

resource "openstack_compute_instance_v2" "logins" {

  for_each = toset(var.login_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair
  availability_zone = var.login_availability_zone

  network {
    uuid = data.openstack_networking_network_v2.cluster.id
  }

  timeouts {
    create = "60m"
    delete = "20m"
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = toset(var.compute_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.compute_image
  flavor_name = var.compute_flavor
  key_pair = var.key_pair
  availability_zone = var.compute_availability_zone

  network {
    uuid = data.openstack_networking_network_v2.cluster.id
  }

  timeouts {
    create = "60m"
    delete = "20m"
  }

}


# resource "openstack_networking_floatingip_v2" "login" {
#   pool = data.openstack_networking_network_v2.external_network.name
# }

# resource "openstack_compute_floatingip_associate_v2" "login" {
#   floating_ip = openstack_networking_floatingip_v2.login.address
#   instance_id = openstack_compute_instance_v2.login.id
# }

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