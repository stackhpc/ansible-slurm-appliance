terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

module "cluster" {
    environment_root = var.environment_root
    source = "../../alaska-common/terraform/modules/cluster"
    cluster_name = "alaska"
    key_pair = "centos-slurm-deploy"
    cluster_net = "iris-alaska-prod-internal"
    cluster_subnet = "iris-alaska-prod-internal"
    rdma_net = "WCDC-iLab-60"
    home_volume = "alaska-prod-home"
    slurmctld_volume = "alaska-prod-slurmctld"
    slurmctl_port = "alaska-prod-slurmctl"
    slurmctl_rdma_port = "alaska-prod-slurmctl-rdma"
    compute_images = {}
    login_nodes = {
      login-0: {
        flavor: "vm.alaska.cpu.himem.quarter"
        image: "ohpc-login-210917-0850.qcow2"
        address: "128.232.222.246"
      }
    }
}
