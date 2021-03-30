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

resource "openstack_networking_secgroup_v2" "secgroup_slurm_login" {
  name        = "secgroup_slurm_login"
  description = "Rules for the slurm login node"
  # Fully manage with terraform
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "secgroup_slurm_compute" {
  name        = "secgroup_slurm_compute"
  description = "Rules for the slurm compute node"
  # Fully manage with terraform
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_slurm_login_rule_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.secgroup_slurm_login.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_slurm_login_rule_ingress_tcp_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  # NOTE: You will want to lock down the ports in a production environment. This will require
  # setting of static ports for the NFS server see:
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config
  port_range_min    = 1
  protocol          = "tcp"
  port_range_max    = 65535
  security_group_id = openstack_networking_secgroup_v2.secgroup_slurm_login.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_slurm_compute_rule_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.secgroup_slurm_compute.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_slurm_compute_rule_ingress_tcp_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 1
  protocol          = "tcp"
  port_range_max    = 65535
  security_group_id = openstack_networking_secgroup_v2.secgroup_slurm_compute.id
}

resource "openstack_compute_instance_v2" "login" {

  name = "${var.cluster_name}-login-0"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair
  network {
    name = var.network
  }
  security_groups = [openstack_networking_secgroup_v2.secgroup_slurm_login.name]
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
  security_groups = [openstack_networking_secgroup_v2.secgroup_slurm_compute.name]
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