# This terraform configuration uses the "skeleton" terraform, so that is checked by CI.

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
    description = "Path to environment root, automatically set by activate script"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources - set by environment var in CI"
}

variable "cluster_image" {
    description = "single image for all cluster nodes - a convenience for CI"
    type = string
    default = "openhpc-240116-1604-b3563a08" # https://github.com/stackhpc/ansible-slurm-appliance/pull/344
    # default = "Rocky-8-GenericCloud-Base-8.9-20231119.0.x86_64.qcow2"
}

variable "cluster_net" {}

variable "cluster_subnet" {}

variable "vnic_type" {
    default = "normal"
}

variable "control_node_flavor" {}

variable "other_node_flavor" {}

variable "volume_backed_instances" {
    default = false
}

module "cluster" {
    source = "../../skeleton/{{cookiecutter.environment}}/terraform/"

    cluster_name = var.cluster_name
    cluster_net = var.cluster_net
    cluster_subnet = var.cluster_subnet
    vnic_type = var.vnic_type
    key_pair = "slurm-app-ci"
    control_node = {
        flavor: var.control_node_flavor
        image: var.cluster_image
    }
    login_nodes = {
        login-0: {
            flavor: var.other_node_flavor
            image: var.cluster_image
        }
    }
    compute_types = {
        small: {
            flavor: var.other_node_flavor
            image: var.cluster_image
        }
        extra: {
            flavor: var.other_node_flavor
            image: var.cluster_image
        }
    }
    compute_nodes = {
        compute-0: "small"
        compute-1: "small"
        compute-2: "extra"
        compute-3: "extra"
    }
    volume_backed_instances = var.volume_backed_instances
    
    environment_root = var.environment_root
    # Can reduce volume size a lot for short-lived CI clusters:
    state_volume_size = 10
    home_volume_size = 20

}
