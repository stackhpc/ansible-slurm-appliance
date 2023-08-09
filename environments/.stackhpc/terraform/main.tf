# This terraform configuration uses the "skeleton" terraform, so that is checked by CI.

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
    default = "openhpc-230809-1401-2aa07061" # https://github.com/stackhpc/ansible-slurm-appliance/pull/299
    # default = "Rocky-8-GenericCloud-Base-8.7-20221130.0.x86_64.qcow2"
    # default = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64.qcow2"
}

variable "cluster_net" {}

variable "cluster_subnet" {}

variable "vnic_type" {}

variable "control_node_flavor" {}

variable "other_node_flavor" {}

variable "volume_backed_instances" {
    default = false
}

variable "state_volume_device_path" {}

variable "home_volume_device_path" {}

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

    state_volume_device_path = var.state_volume_device_path
    home_volume_device_path = var.home_volume_device_path
}
