variable "environment_root" {
   type = string
   description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../site/tofu/"
    
    cluster_name = "slurm-staging"
    cluster_networks = [
      {
        network = "slurm-staging-control-net"
        subnet = "slurm-staging-control-subnet"
        no_security_groups: true
        port_security_enabled: false
      },
      {
        network = "slurm-staging-rdma-net"
        subnet = "slurm-staging-rdma-subnet"
        no_security_groups: true
        port_security_enabled: false
      },
      {
        network = "external-ceph"
        subnet = "external-ceph"
      }
    ]
    compute = {
      general-gen2-rack6 = {
          nodes: [
		"stagingcompute000",
		"stagingcompute001",
                #"stagingcompute002",
                #"stagingcompute003",
                #"stagingcompute004",
                #"stagingcompute005",
                #"stagingcompute006",
                #"stagingcompute007",
	  ]
          flavor: "hpc.v2.32cpu.128ram" # TODO: make this a 32cpu gen1 once there's space
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-staging-control-net": "normal"
            "slurm-staging-rdma-net": "direct"
            "external-ceph": "direct"
          }
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
    }

    login = {
        interactive = {
            nodes: ["staginglogin"]
            flavor: "hpc.v2.32cpu.128ram" # TODO: make this a 16cpu gen1 once there's space
            availability_zone = "DL-Rack-6"
            vnic_types = {
              "slurm-staging-control-net": "normal"
              "slurm-staging-rdma-net": "direct"
              "external-ceph": "direct"
            }
            root_volume_size = 100
            server_group_id = openstack_compute_servergroup_v2.control.id
            fip_addresses:  ["10.3.0.159"]
            fip_network: "slurm-staging-control-net"
        }
    }
  

    control_server_group_id = openstack_compute_servergroup_v2.control.id

    control_node_flavor = "hpc.v2.32cpu.128ram" # TODO: make this a 16cpu gen1 once there's space (remove this one and rely on site)

    environment_root = var.environment_root
}
