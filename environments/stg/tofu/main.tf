# tflint-ignore: terraform_required_version

variable "environment_root" {
  type        = string
  description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
  source           = "../../site/tofu/"
  environment_root = var.environment_root

  # whole-cluster parameters:
  cluster_name          = "staging"
  cluster_domain_suffix = "eri.agresearch.co.nz"
  cluster_networks = [
    {
      network = "nesi-hpc-baremetal-vlan112"
      subnet  = "nesi-hpc-baremetal-vlan112"
    }
  ]

  # control node:
  control_ip_addresses = {
    nesi-hpc-baremetal-vlan112 = "10.1.112.100"
  }

  # login nodes (all VM):
  login = {
    login_shell = {
      nodes  = ["login-0"]
      flavor = "agr.compute1.32cpu64ram"
      extra_networks = [
        {
          network = "agr-vlan107"
          subnet  = "agr-vlan107"
        }
      ]
      gateway_ip = "10.29.107.254" # Removes gateway from vlan112 interface
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = ["10.1.112.120"]
        agr-vlan107                = ["10.29.107.120"]
      }
    }
    openondemand = {
      nodes  = ["ondemand"]
      flavor = "agr.compute1.32cpu64ram"
      extra_networks = [
        {
          network = "agr-vlan107"
          subnet  = "agr-vlan107"
        }
      ]
      gateway_ip = "10.29.107.254" # see above
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = ["10.1.112.130"]
        agr-vlan107                = ["10.29.107.130"]
      }
    }
  }

  # compute nodes - mix of VM and BM:
  compute = {
    baremetal = {
      nodes             = [] # TODO: ["a02co12"]
      match_ironic_node = true
      flavor            = "agr.metal1.compute"
      vnic_types = {
        nesi-hpc-baremetal-vlan112 = "baremetal"
      }
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = [
          "10.1.112.145"
        ]
      }
    }
    interactive = {
      nodes  = ["interactive-0", "interactive-1"]
      flavor = "agr.compute1.8cpu16ram"
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = [
          "10.1.112.150",
          "10.1.112.151"
        ]
      }
    }
    hugemem = {
      nodes             = []
      match_ironic_node = true
      flavor            = "agr.metal1.hugemem"
      vnic_types = {
        nesi-hpc-baremetal-vlan112 = "baremetal"
      }
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = [
          "10.1.112.160",
          "10.1.112.161"
        ]
      }
    }
    gpu = {
      nodes             = []
      match_ironic_node = true
      flavor            = "agr.metal1.gpua100"
      vnic_types = {
        nesi-hpc-baremetal-vlan112 = "baremetal"
      }
      # image = TODO
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = [
          "10.1.112.170"
        ]
      }
    }
    vgpu = {
      nodes  = []
      flavor = "agr.gpu1.cpu32ram448.a10.1g.24gb"
      # image = TODO
      ip_addresses = {
        nesi-hpc-baremetal-vlan112 = [
          "10.1.112.180",
          "10.1.112.181"
        ]
      }
    }
  }
}
