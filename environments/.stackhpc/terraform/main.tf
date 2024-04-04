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

variable "os_version" {
  type = string
  description = "RL8 or RL9"
}

variable "cluster_image" {
    description = "single image for all cluster nodes, keyed by os_version - a convenience for CI"
    type = map(string)
    default = {
        # https://github.com/stackhpc/ansible-slurm-appliance/pull/353
        RL8: "openhpc-ofed-RL8-240404-1407-e9fe3235"
        RL9: "openhpc-ofed-RL9-240404-1503-e9fe3235"
    }
}

variable "cluster_net" {}

variable "cluster_subnet" {}

variable "vnic_type" {
    default = "normal"
}

variable "state_volume_type"{
    default = null
}

variable "home_volume_type"{
    default = null
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
        image: var.cluster_image[var.os_version]
    }
    login_nodes = {
        login-0: {
            flavor: var.other_node_flavor
            image: var.cluster_image[var.os_version]
        }
    }
    compute_types = {
        standard: { # NB: can't call this default!
            flavor: var.other_node_flavor
            image: var.cluster_image[var.os_version]
        }
        # Example of how to add another partition:
        # extra: {
        #     flavor: var.other_node_flavor
        #     image: var.cluster_image[var.os_version]
        # }
    }
    compute_nodes = {
        compute-0: "standard"
        compute-1: "standard"
        # compute-2: "extra"
        # compute-3: "extra"
    }
    volume_backed_instances = var.volume_backed_instances
    
    environment_root = var.environment_root
    # Can reduce volume size a lot for short-lived CI clusters:
    state_volume_size = 10
    home_volume_size = 20

    state_volume_type = var.state_volume_type
    home_volume_type = var.home_volume_type

}
