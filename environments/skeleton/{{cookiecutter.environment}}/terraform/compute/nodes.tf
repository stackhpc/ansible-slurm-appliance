resource "openstack_networking_port_v2" "compute" {

  for_each = toset(var.nodes)

  name = "${var.cluster_name}-${each.key}"
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

  user_data = <<-EOF
    #cloud-config
    fqdn: ${var.cluster_name}-${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
  EOF

}

output "compute_instances" {
    value = openstack_compute_instance_v2.compute
}
