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
  volume_backed_instances = lookup(each.value, "volume_backed_instances", var.volume_backed_instances)
  root_volume_size = lookup(each.value, "root_volume_size", var.root_volume_size)
  gateway_ip = lookup(each.value, "gateway_ip", var.gateway_ip)
  nodename_template = lookup(each.value, "nodename_template", var.cluster_nodename_template)

  # optionally set for group:
  networks = concat(var.cluster_networks, lookup(each.value, "extra_networks", []))
  # here null means "use module var default"
  extra_volumes = lookup(each.value, "extra_volumes", null)
  compute_init_enable = lookup(each.value, "compute_init_enable", null)
  ignore_image_changes = lookup(each.value, "ignore_image_changes", null)
  match_ironic_node = lookup(each.value, "match_ironic_node", null)
  availability_zone = lookup(each.value, "availability_zone", null)

  # computed
  # not using openstack_compute_instance_v2.control.access_ip_v4 to avoid
  # updates to node metadata on deletion/recreation of the control node:
  control_address = openstack_networking_port_v2.control[var.cluster_networks[0].network].all_fixed_ips[0]
  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]
  baremetal_nodes = data.external.baremetal_nodes.result
  
  # input dict validation:
  group_name = each.key
  group_keys = keys(each.value)
  allowed_keys = [
    "nodes",
    "flavor",
    "image_id",
    "extra_networks",
    "vnic_types",
    "compute_init_enable",
    "ignore_image_changes",
    "volume_backed_instances",
    "root_volume_size",
    "extra_volumes",
    "match_ironic_node",
    "availability_zone",
    "gateway_ip",
    "nodename_template",
  ]
}
