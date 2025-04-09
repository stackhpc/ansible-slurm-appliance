variable "environment_root" {
   type = string
   description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../site/tofu/"

    cluster_name = "slurm-staging"
    cluster_networks = [
      {
        network = "slurm-staging"
        subnet = "slurm-staging"
      }
    ]
    vnic_types = {
      "slurm-staging" = "direct"
      "external-ceph" = "direct"
    }

    environment_root = var.environment_root
}
