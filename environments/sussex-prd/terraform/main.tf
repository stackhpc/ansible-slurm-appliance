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

variable "cluster_image_id" {
    type = string
    default = "fa21f5a7-184a-496b-8570-62db2314eb32" # openhpc-ofed-RL9-240621-1308-96959324, v1.149
}

module "cluster" {
    source = "../../sussex-base/terraform/"
    environment_root = var.environment_root

    cluster_name = var.cluster_name
    key_pair = "slurm-app-ci"
    cluster_image_id = var.cluster_image_id

    tenant_net = "slurm"
    tenant_subnet = "slurm"
    storage_net = "slurm-data"
    storage_subnet = "slurm-data"

    control_node_flavor = "general.v1.16cpu.32gb"

    login_nodes = {
        "login-0" = {
            flavor = "general.v1.16cpu.32gb"
            fip = # TODO
        }
    }

    compute = {
      standard = {
          flavor = "general.v1.16cpu.32gb"
          nodes = [
            "general",
            "general",
          ]
      }
    }
}
