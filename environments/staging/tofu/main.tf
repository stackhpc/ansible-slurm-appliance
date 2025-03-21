variable "environment_root" {
  type = string
  description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
  source = "../../site/tofu/"

  cluster_name = "staging"
  cluster_networks = [
    {
      network = "netapp"
      subnet = "netapp"
    }
  ]
  key_pair = "rally"
  control_node_flavor = "m1.xlarge"
  login = {
    # Arbitrary group name for these login nodes
    interactive = {
      nodes = ["login-01"]
      flavor = "m1.xlarge"
      fip_addresses = ["194.199.232.111"]
    }
  }
  # RL9.4 + OFED 24.10-1.1.4.0 + SSSD
  cluster_image_id = "479747da-bfcd-4aec-81f0-8c9475e2d461"
  compute = {
    # Group name used for compute node partition definition
    cpu = {
      flavor = "baremetal"
      nodes = [
        "io-cpu-51",
        "io-cpu-52",
      ]
      extra_networks = [
        {
          network = "infiniband"
          subnet = "infiniband"
          no_security_groups = true
        }
      ]
      match_ironic_node = true
      use_ironic_node_name = true
      vnic_types = {
        netapp = "baremetal"
        infiniband = "baremetal"
      }
    }
  }

  environment_root = var.environment_root
}
