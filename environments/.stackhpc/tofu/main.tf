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
    source = "../../skeleton/{{cookiecutter.environment}}/tofu/"

    cluster_name = var.cluster_name
    cluster_net = var.cluster_net
    cluster_subnet = var.cluster_subnet
    vnic_type = var.vnic_type
    key_pair = "slurm-app-ci"
    cluster_image_id = data.openstack_images_image_v2.cluster.id
    control_node_flavor = var.control_node_flavor
    # have to override default, as unusually the actual module path and secrets
    # are not in the same environment for stackhpc
    inventory_secrets_path = "${path.module}/../inventory/group_vars/all/secrets.yml"

    login = {
        login: {
            nodes: ["login-0"]
            flavor: var.other_node_flavor
        }
    }
    compute = {
        standard: { # NB: can't call this default!
            nodes: ["compute-0", "compute-1"]
            flavor: var.other_node_flavor
            compute_init_enable: ["compute", "etc_hosts", "nfs", "basic_users", "eessi"]
            # ignore_image_changes: true
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
