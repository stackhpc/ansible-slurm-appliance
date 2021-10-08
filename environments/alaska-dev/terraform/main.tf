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
    cluster_net = "iris-alaska-dev-internal"
    cluster_subnet = "iris-alaska-dev-internal"
    rdma_net = "WCDC-iLab-60"
    home_volume = "alaska-dev-home"
    slurmctld_volume = "alaska-dev-slurmctld"
    slurmctl_port = "alaska-dev-slurmctl"
    slurmctl_rdma_port = "alaska-dev-slurmctl-rdma"
    compute_nodes = {
      compute-0: "small"
      compute-1: "small"
      // compute-2: "small"
      // compute-3: "small"
    }
    login_nodes = {
      login-0: {
        flavor: "vm.alaska.cpu.general.small"
        image: "CentOS8-2105"
        address: "128.232.222.71"
      }
    }
    control_node = {
      flavor: "vm.alaska.cpu.general.small"
      image: "CentOS8-2105"
    }
}
