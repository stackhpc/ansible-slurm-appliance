variable "environment_root" {
   type = string
   description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../site/tofu/"

    cluster_name = "slurm-production"
    volume_backed_instances = true
    cluster_networks = [
      {
        network = "slurm-production"
        subnet = "slurm-production"
      },
      {
        network = "external-ceph"
        subnet = "external-ceph"
      }
    ]
    vnic_types = {
      "slurm-production" = "normal"
      "external-ceph" = "normal"
    }
    compute = {
      # Group name used for compute node partition definition
      general = {
          nodes: [
            "compute-0",
            "compute-1"
          ]
          flavor: "hpc.v2.32cpu.128ram"
      }
      gpu = {
          nodes: [
            "gpu-0",
            "gpu-1",
            "gpu-2",
            "gpu-3",
          ]
          flavor: "hpc.v2.16cpu.128ram.a100"
      }
      highmem = {
          nodes: [
            "highmem-0",
            "highmem-1",
          ]
          flavor: "hpc.v2.60cpu.480ram"
      }
  }

    environment_root = var.environment_root
}
