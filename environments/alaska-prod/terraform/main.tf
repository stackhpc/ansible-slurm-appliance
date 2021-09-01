terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

module "cluster" {
    source = "../../alaska-common/terraform/modules/cluster"
    cluster_name = "alaska"
    key_pair = "centos-slurm-deploy"
    cluster_net = "iris-alaska-prod-internal"
    cluster_subnet = "iris-alaska-prod-internal"
    // rdma_net = "WCDC-iLab-60"
    home_volume = "alaska-prod-home"
    slurmctld_volume = "alaska-prod-slurmctld"
    slurmctl_port = "alaska-prod-slurmctl"
}
