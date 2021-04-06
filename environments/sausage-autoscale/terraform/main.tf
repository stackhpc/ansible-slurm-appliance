terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "environment_root" {
  type = string
}

variable "compute_names" {
  default = ["compute-0", "compute-1"]
}

variable "cluster_name" {
  default = "testohpc"
}

variable "key_pair" {
  type = string
}

variable "network" {
  type = string
}

variable "login_flavor" {
  type = string
}

variable "login_image" {
  type = string
}

variable "compute_flavor" {
  type = string
}

variable "compute_image" {
  type = string
}

resource "openstack_compute_instance_v2" "login" {

  name = "${var.cluster_name}-login-0"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair
  network {
    name = var.network
  }
}


resource "openstack_compute_instance_v2" "compute" {

  for_each = toset(var.compute_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.compute_image
  flavor_name = var.compute_flavor
  #flavor_name = "compute-A"
  key_pair = var.key_pair
  network {
    name = var.network
  }
}

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "login": openstack_compute_instance_v2.login,
                            "computes": openstack_compute_instance_v2.compute,
                          },
                          )
  filename = "${var.environment_root}/inventory/hosts"
}