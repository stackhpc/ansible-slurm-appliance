resource "openstack_networking_port_v2" "compute" {

  for_each = toset(var.nodes)

  name = "${var.cluster_name}-${each.key}"
  dns_name = var.dns == "neutron" ? "${var.cluster_name}-${each.key}" : null
  network_id = var.cluster_net_id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = var.cluster_subnet_id
  }

  security_group_ids = var.security_group_ids

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_compute_instance_v2" "compute" {

  for_each = toset(var.nodes)
  
  name = "${var.cluster_name}-${each.key}"
  image_id = var.image_id
  flavor_name = var.flavor
  key_pair = var.key_pair

  dynamic "block_device" {
    for_each = var.volume_backed_instances ? [1]: []
    content {
      uuid = var.image_id
      source_type  = "image"
      destination_type = "volume"
      volume_size = var.root_volume_size
      boot_index = 0
      delete_on_termination = true
    }
  }
  
  network {
    port = openstack_networking_port_v2.compute[each.key].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

resource "openstack_dns_recordset_v2" "compute" {

  for_each = var.dns == "designate" ? toset(var.nodes) : []
  
  zone_id = var.cluster_dns_zone["cluster"].id
  name = "${var.cluster_name}-${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}."
  type = "A"
  records = [for n in openstack_compute_instance_v2.compute[each.key].network: n.fixed_ip_v4 if n.access_network]
}


output "compute_instances" {
    value = openstack_compute_instance_v2.compute
}
