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
    default = "stg"
}

module "cluster" {
    source = "../../sussex-base/terraform/"
    environment_root = var.environment_root

    cluster_name = var.cluster_name
    key_pair = "slurm-deploy-v2"

    login_nodes = {
        "login-0" = {
            flavor = "general.v1.16cpu.32gb"
            fip = "139.184.83.151"
        }
    }

    compute = {
      general = {
          flavor = "general.v1.16cpu.32gb"
          nodes = [
            "general-0",
            "general-1",
          ]
          inventory_groups = ["cuda"]
      }
      a40 = {
        flavor = "baremetal.r7525.256cpu.a40"
        image_id = "9fa9cc54-7447-4204-8d88-aaf0f314c648" # openhpc-extra-RL9-240723-1238-b5de8392
        vnic_type = "baremetal"
        availability_zone_prefix = "nova::artemis-node-" # last portion of node name = hypervisor hostname
        nodes = [
          "a40-300",
          "a40-301",
        ]
        inventory_groups = ["cuda"]
      }
    }
}
