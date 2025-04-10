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
      },
      {
        network = "external-ceph"
        subnet = "external-ceph"
      }
    ]
    compute = {
      # Group name used for compute node partition definition
      general = {
          nodes: [
            "compute-0",
            "compute-1",
            "compute-2",
            "compute-3",
            "compute-4",
            "compute-5",
            "compute-6",
            "compute-7",
            "compute-8",
            "compute-9",
            "compute-10",
            "compute-11",
            "compute-12",
            "compute-13"
          ]
          flavor: "hpc.v2.32cpu.128ram"
          vnic_types = {
            "slurm-staging" = "direct"
            "external-ceph" = "direct"
          }
      }
  }

    environment_root = var.environment_root
}
