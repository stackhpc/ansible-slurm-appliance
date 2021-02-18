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
    description = "A list of hostnames for the compute nodes"
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

data "openstack_networking_network_v2" "cluster" {
  name = var.cluster_network
}

resource "openstack_compute_instance_v2" "control" {
  name = "${var.cluster_name}-control"
  image_name = var.control_image
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  
  network {
    uuid = data.openstack_networking_network_v2.cluster.id
  }

  timeouts {
    create = "60m"
    delete = "20m"
  }

}

resource "openstack_compute_instance_v2" "login" {
  name = "${var.cluster_name}-login-0"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair

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
                            "login": openstack_compute_instance_v2.login,
                            "computes": openstack_compute_instance_v2.compute,
                            # "fip": openstack_networking_floatingip_v2.login
                          },
                          )
  filename = "../inventory/hosts"
}