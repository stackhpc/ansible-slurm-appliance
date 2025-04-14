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
    vnic_types = {
      "slurm-staging" = "normal"
      "external-ceph" = "normal"
    }
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
      }
      # gpu = {
      #     nodes: [
      #       "gpu-0",
      #       "gpu-1",
      #     ]
      #     flavor: "hpc.v2.16cpu.128ram.a100"
      # }
      # highmem = {
      #     nodes: [
      #       "highmem-0",
      #       "highmem-1",
      #     ]
      #     flavor: "hpc.v2.60cpu.480ram"
      # }
  }

    environment_root = var.environment_root
}
