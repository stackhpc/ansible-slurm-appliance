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
    default = "prd"
}

module "cluster" {
    source = "../../sussex-base/terraform/"
    environment_root = var.environment_root

    cluster_name = var.cluster_name
    key_pair = "slurm-deploy-v2"

    login_nodes = {
        "login-0" = {
            flavor = "general.v1.16cpu.32gb"
            fip = "139.184.83.139"
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
      grid = {
          flavor = "baremetal.gridpp.r6525.128cpu"
          vnic_type = "baremetal"
          nodes = [
            "grid-0",
            "grid-1",
          ]
      }
    }
}
