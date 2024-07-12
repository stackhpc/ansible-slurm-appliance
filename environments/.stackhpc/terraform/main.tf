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
  default = "RL9"
}

variable "cluster_image" {
    description = "single image for all cluster nodes, keyed by os_version - a convenience for CI"
    type = map(string)
    default = {
        # https://github.com/stackhpc/ansible-slurm-appliance/pull/410
        RL8: "openhpc-RL8-240712-1426-6830f97b"
        RL9: "openhpc-ofed-RL9-240712-1425-6830f97b"
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

data "openstack_images_image_v2" "cluster" {
    name = var.cluster_image[var.os_version]
    most_recent = true
}

module "cluster" {
    source = "../../skeleton/{{cookiecutter.environment}}/terraform/"

    cluster_name = var.cluster_name
    cluster_net = var.cluster_net
    cluster_subnet = var.cluster_subnet
    vnic_type = var.vnic_type
    key_pair = "slurm-app-ci"
    cluster_image_id = data.openstack_images_image_v2.cluster.id
    control_node_flavor = var.control_node_flavor

    login_nodes = {
        login-0: var.other_node_flavor
    }
    compute = {
        standard: { # NB: can't call this default!
            nodes: ["compute-0", "compute-1"]
            flavor: var.other_node_flavor
        }
        # Example of how to add another partition:
        # extra: {
        #     nodes: ["compute-2", "compute-3"]
        #     flavor: var.other_node_flavor
        # }
    }
    
    volume_backed_instances = var.volume_backed_instances
    
    environment_root = var.environment_root
    # Can reduce volume size a lot for short-lived CI clusters:
    state_volume_size = 10
    home_volume_size = 20

    state_volume_type = var.state_volume_type
    home_volume_type = var.home_volume_type

}
