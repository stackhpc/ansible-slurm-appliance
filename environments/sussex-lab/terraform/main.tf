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

    compute = {
      standard = {
          flavor = "en1.xsmall"
          nodes = [
            "standard-0",
            "standard-1",
          ]
      }
    }
}

# TODO: give this a persistent volume used for home!
resource "openstack_compute_instance_v2" "nfs_server" {

  name = "sussexlab-nfs"
  image_id = "5e353672-c03c-43fc-9fb7-71ccaaee4047" # openhpc-RL9-240327-1026-4812f852
  flavor_name = "en1.xsmall"
  key_pair = "slurm-app-ci"

  network {
    name = "sussex-storage"
    access_network = true
  }

  security_groups = ["sussexlab-cluster"]

  metadata = {
    environment_root = var.environment_root
  }
}

resource "local_file" "nfs" {
  content  = <<-EOT
  [nfs_server]
  ${openstack_compute_instance_v2.nfs_server.name} ansible_host=${[for n in openstack_compute_instance_v2.nfs_server.network: n.fixed_ip_v4 if n.access_network][0]} instance_id=${ openstack_compute_instance_v2.nfs_server.id }
  EOT
  filename = "../inventory/additional_hosts"
}
