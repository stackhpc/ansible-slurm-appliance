locals {
  all_compute_volumes = {for v in setproduct(var.nodes, keys(var.volumes)): "${v[0]}-${v[1]}" => {"node" = v[0], "volume" = v[1]}}
  # e.g. with
  # var.nodes = ["compute-0", "compute-1"]
  # var.volumes = {
  #     "vol-a" = {size = 10},
  #     "vol-b" = {size = 20}
  # }
  # this is a mapping with
  # keys "compute-0-vol-a", "compute-0-vol-b" ...
  # values which are a mapping e.g. {"node"="compute-0", "volume"="vol-a"}
}

resource "openstack_blockstorage_volume_v3" "compute" {
    
    for_each = local.all_compute_volumes

    name = "${var.cluster_name}-${each.key}"
    description = "Compute node ${each.value.node} volume ${each.value.volume}"
    size = var.volumes[each.value.volume].size
}

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

  # root device:
  block_device {
    uuid = var.image_id
    source_type  = "image"
    destination_type = var.volume_backed_instances ? "volume" : "local"
    volume_size = var.volume_backed_instances ? var.root_volume_size : null
    boot_index = 0
    delete_on_termination = true
  }
  
  # additional volumes:
  dynamic "block_device" {
    for_each = var.volumes
    content {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = openstack_blockstorage_volume_v3.compute["${each.key}-${block_device.key}"].id
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
