variable "environment_root" {
   type = string
   description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../site/tofu/"

    cluster_name = "slurm-production"
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
      "slurm-production" = "direct"
      "external-ceph" = "direct"
    }
    compute = {
      # Group name used for compute node partition definition
      general = {
          nodes: [
            "compute-00",
            "compute-01",
            "compute-02",
            "compute-03",
            "compute-04",
            "compute-05",
            "compute-06",
            "compute-07",
            "compute-08",
            "compute-09",
            "compute-10",
            "compute-11",
            "compute-12",
            "compute-13",
            "compute-14",
            "compute-15",
            "compute-16",
            "compute-17",
            "compute-18",
            "compute-19",
            "compute-20",
            "compute-21",
            "compute-22",
            "compute-23",
            "compute-24",
            "compute-25",
            "compute-26",
            "compute-27",
            "compute-28",
            "compute-29",
            "compute-30",
            "compute-31",
            "compute-32",
            "compute-33",
            "compute-34",
            "compute-35",
            "compute-36",
            "compute-37",
          ]
          flavor: "hpc.v2.32cpu.128ram"
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      gpu = {
          nodes: [
            "gpu-00",
            "gpu-01",
            "gpu-02",
            "gpu-03",
          ]
          flavor: "hpc.v2.16cpu.128ram.a100"
          ignore_image_changes: true
      }
      highmem = {
          nodes: [
            "highmem-00",
            "highmem-01",
          ]
          flavor: "hpc.v2.56cpu.448ram"
          ignore_image_changes: true
      }
    }

    login = {
        interactive = {
            nodes: ["login-0"]
            flavor: "hpc.v2.16cpu.64ram"
            root_volume_size = 100
            server_group_id = openstack_compute_servergroup_v2.control.id
            fip_addresses:  ["10.129.31.194"]
            fip_network: "slurm-production"
        }
    }

    control_server_group_id = openstack_compute_servergroup_v2.control.id

    environment_root = var.environment_root
}
