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
      }
      a40 = {
        flavor = "baremetal.r7525.256cpu.a40"
        image_id = "bbffdb18-5dbb-4271-ba8f-950c2cbdd616" # openhpc-extra-RL9-240719-1402-bc56229b
        vnic_type = "baremetal"
        nodes = [
          "a40-0",
        ]
      }
    }
}
