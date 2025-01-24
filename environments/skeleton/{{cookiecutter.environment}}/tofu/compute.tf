module "compute" {
  source = "./node_group"

  for_each = var.compute

  # must be set for group:
  nodes = each.value.nodes
  flavor = each.value.flavor

  # always taken from top-level value:
  cluster_name = var.cluster_name
  cluster_domain_suffix = var.cluster_domain_suffix
  key_pair = var.key_pair
  environment_root = var.environment_root
  
  # can be set for group, defaults to top-level value:
  image_id = lookup(each.value, "image_id", var.cluster_image_id)
  vnic_types = lookup(each.value, "vnic_types", var.vnic_types)
  vnic_profiles = lookup(each.value, "vnic_profiles", var.vnic_profiles)
  volume_backed_instances = lookup(each.value, "volume_backed_instances", var.volume_backed_instances)
  root_volume_size = lookup(each.value, "root_volume_size", var.root_volume_size)
  
  # optionally set for group
  networks = concat(var.cluster_networks, lookup(each.value, "extra_networks", []))
  extra_volumes = lookup(each.value, "extra_volumes", {})
  compute_init_enable = lookup(each.value, "compute_init_enable", [])
  ignore_image_changes = lookup(each.value, "ignore_image_changes", false)

  # computed
  k3s_token = local.k3s_token
  control_address = openstack_compute_instance_v2.control.access_ip_v4
  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]
}
