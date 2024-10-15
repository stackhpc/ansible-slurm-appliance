module "compute" {
  source = "./compute"

  for_each = var.compute

  nodes = each.value.nodes
  cluster_name = var.cluster_name
  cluster_domain_suffix = var.cluster_domain_suffix
  cluster_net_id = data.openstack_networking_network_v2.cluster_net.id
  cluster_subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id

  flavor = each.value.flavor
  image_id = lookup(each.value, "image_id", var.cluster_image_id)
  vnic_type = lookup(each.value, "vnic_type", var.vnic_type)
  vnic_profile = lookup(each.value, "vnic_profile", var.vnic_profile)
  key_pair = var.key_pair
  volumes = lookup(each.value, "volumes", {})

  environment_root = var.environment_root
  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]
}
