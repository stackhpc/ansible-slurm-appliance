terraform {
  required_version = ">= 0.13"
}

provider "openstack" { # uses clouds.yml
  cloud = "alaska"
  version = "~> 1.25"
}

variable "compute_names" {
  default = ["compute-0", "compute-1"]
}

variable "cluster_name" {
  default = "testohpc"
}

variable "node_image" {
  #default = "CentOS-7-x86_64-GenericCloud-2020-04-22"
  default = "CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64"
  #default = "CentOS7.8" #-OpenHPC"
}

resource "openstack_compute_instance_v2" "login" {

  name = "${var.cluster_name}-login-0"
  image_name = var.node_image
  flavor_name = "general.v1.small"
  key_pair = "id-rsa-alaska"
  network {
    name = "ilab"
  }
}


resource "openstack_compute_instance_v2" "compute" {

  for_each = toset(var.compute_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.node_image
  flavor_name = "general.v1.small"
  #flavor_name = "compute-A"
  key_pair = "id-rsa-alaska"
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
