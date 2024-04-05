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

module "cluster" {
    source = "../../sussex-base/terraform/"
    environment_root = var.environment_root

    cluster_name = "sussexlab"
    key_pair = "slurm-app-ci"
    cluster_image_id = "5e353672-c03c-43fc-9fb7-71ccaaee4047" # openhpc-RL9-240327-1026-4812f852

    tenant_net = "sussex-tenant"
    tenant_subnet = "sussex-tenant"
    storage_net = "sussex-storage"
    storage_subnet = "sussex-storage"

    control_node_flavor = "ec1.medium"

    login_nodes = {
        "login-0" = {
            flavor = "en1.xsmall"
            fip = "195.114.30.210"
        }
    }

    compute_nodes = {
        standard-0: "en1.xsmall"
        standard-1: "en1.xsmall"
    }
}

