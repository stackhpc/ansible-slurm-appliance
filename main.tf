terraform {
  required_version = ">= 0.13"
}

variable "cloud" {
  type = string
  description = "Name of openstack cloud to use, from clouds.yaml file"
}

provider "openstack" { # uses clouds.yml
  cloud = var.cloud
  version = "~> 1.25"
}

variable "compute_names" {
  type = list(string)
  description = "List of compute node hostname suffixes"
  default = []
}

variable "cluster_name" {
  type = string
  description = "Name of cluster (used as prefix)"
}

variable "key_pair" {
  type = string
  description = "Name of keypair in openstack"
}

variable "login_image" {
  type = string
  description = "Name of image in openstack to use for login/control node"
}

variable "compute_image" {
  type = string
  description = "Name of image in openstack to use for compute nodes"
}

resource "openstack_compute_instance_v2" "login" {

  name = "${var.cluster_name}-login-0"
  image_name = var.login_image
  flavor_name = "general.v1.small"
  key_pair = var.key_pair
  network {
    name = "ilab"
  }
}


resource "openstack_compute_instance_v2" "compute" {

  for_each = toset(var.compute_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.compute_image
  flavor_name = "general.v1.small"
  #flavor_name = "compute-A"
  key_pair = var.key_pair
  network {
    name = "ilab"
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
  filename = "${path.module}/inventory"
}
