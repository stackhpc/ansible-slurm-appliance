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

variable "cluster_image_id" {
    type = string
    default = "063d2f2e-6c53-4f14-a7fd-e557df645794" # openhpc-ofed-RL9-240621-1308-96959324, v1.149
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

    control_node_flavor = "general.v1.4cpu.8gb"

    login_nodes = {
        "login-0" = {
            flavor = "general.v1.4cpu.8gb"
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
