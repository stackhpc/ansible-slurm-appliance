# tflint-ignore: terraform_required_providers
locals {
  subnet_keys = ["name", "cidr"]
}
resource "local_file" "hosts" {
  content = templatefile("${path.module}/inventory.tpl",
    {
      "cluster_name" : var.cluster_name,
      "cluster_domain_suffix" : var.cluster_domain_suffix
      "control" : openstack_compute_instance_v2.control
      "control_fqdn" : local.control_fqdn
      "login_groups" : module.login
      "compute_groups" : module.compute
      "additional_groups" : module.additional
      "state_dir" : var.state_dir
      "cluster_home_volume" : var.home_volume_provisioning != "none"
      "cluster_subnets" : [for net in var.cluster_networks : { for k, v in data.openstack_networking_subnet_v2.cluster_subnet[net.network] : k => v if contains(local.subnet_keys, k) }]
    },
  )
  filename = "../inventory/hosts.yml"
}
