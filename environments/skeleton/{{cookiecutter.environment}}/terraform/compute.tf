module "compute" {
  source = "./compute"

  for_each = var.compute

  # must be set for group:
  nodes = each.value.nodes
  flavor = each.value.flavor

  cluster_name = var.cluster_name
  cluster_domain_suffix = var.cluster_domain_suffix
  cluster_net_id = data.openstack_networking_network_v2.cluster_net.id
  cluster_subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id

  # can be set for group, defaults to top-level value:
  image_id = lookup(each.value, "image_id", var.cluster_image_id)
  vnic_type = lookup(each.value, "vnic_type", var.vnic_type)
  vnic_profile = lookup(each.value, "vnic_profile", var.vnic_profile)
  volume_backed_instances = lookup(each.value, "volume_backed_instances", var.volume_backed_instances)
  root_volume_size = lookup(each.value, "root_volume_size", var.root_volume_size)
  extra_volumes = lookup(each.value, "extra_volumes", {})

  compute_init_enable = lookup(each.value, "compute_init_enable", [])

  key_pair = var.key_pair
  environment_root = var.environment_root
  k3s_token = var.k3s_token
  control_address = [for n in openstack_compute_instance_v2.control["control"].network: n.fixed_ip_v4 if n.access_network][0]
  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]
  baremetal_nodes = data.external.baremetal_nodes.result
}
