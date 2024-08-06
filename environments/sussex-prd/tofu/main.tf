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
      a40_1024 = {
        flavor = "baremetal.r7525.128cpu.1tbram.a40"
        image_id = "9fa9cc54-7447-4204-8d88-aaf0f314c648" # openhpc-extra-RL9-240723-1238-b5de8392
        vnic_type = "baremetal"
        nodes = [ # use -10 for 1TB nodes
          "a40-10",
          "a40-11",
          "a40-12",
          "a40-13",
          "a40-14",
         ]
      }
      a40_512 = {
        flavor = "baremetal.r7525.128cpu.512gbram.a40"
        image_id = "9fa9cc54-7447-4204-8d88-aaf0f314c648" # openhpc-extra-RL9-240723-1238-b5de8392
        vnic_type = "baremetal"
        nodes = [ # use -00 for 500GB nodes
          "a40-00",
          "a40-01",
          "a40-02",
        ]
      }
    }
}
