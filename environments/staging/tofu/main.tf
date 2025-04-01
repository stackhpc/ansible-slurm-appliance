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

    environment_root = var.environment_root
}
