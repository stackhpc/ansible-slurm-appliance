locals {
  control_volumes = concat([openstack_blockstorage_volume_v3.state], var.home_volume_size > 0 ? [openstack_blockstorage_volume_v3.home][0] : [])
}

resource "openstack_networking_port_v2" "control" {

  for_each = {for net in var.cluster_networks: net.network => net}

  name = "${var.cluster_name}-control-${each.key}"
  network_id = data.openstack_networking_network_v2.cluster_net[each.key].id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster_subnet[each.key].id
  }

  no_security_groups = lookup(each.value, "no_security_groups", false)
  security_group_ids = lookup(each.value, "no_security_groups", false) ? [] : [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]

  binding {
    vnic_type = lookup(var.vnic_types, each.key, "normal")
  }
}

resource "openstack_compute_instance_v2" "control" {
  
  name = "${var.cluster_name}-control"
  image_id = var.cluster_image_id
  flavor_name = var.control_node_flavor
  key_pair = var.key_pair
  
  # root device:
  block_device {
      uuid = var.cluster_image_id
      source_type  = "image"
      destination_type = var.volume_backed_instances ? "volume" : "local"
      volume_size = var.volume_backed_instances ? var.root_volume_size : null
      boot_index = 0
      delete_on_termination = true
  }

  dynamic "block_device" {
    for_each = local.control_volumes
    content {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = block_device.value.id # actually openstack_blockstorage_volume_v3 id
    }
  }

  dynamic "network" {
    for_each = {for net in var.cluster_networks: net.network => net}
    content {
      port = openstack_networking_port_v2.control[network.key].id
      access_network = network.key == var.cluster_networks[0].network
    }
  }

  metadata = {
    environment_root = var.environment_root
    access_ip = openstack_networking_port_v2.control[var.cluster_networks[0].network].all_fixed_ips[0]
  }

  user_data = <<-EOF
    #cloud-config
    fqdn: ${var.cluster_name}-control.${var.cluster_name}.${var.cluster_domain_suffix}
    
    bootcmd:
      %{for volume in local.control_volumes}
      - BLKDEV=$(readlink -f $(ls /dev/disk/by-id/*${substr(volume.id, 0, 20)}* | head -n1 )); blkid -o value -s TYPE $BLKDEV ||  mke2fs -t ext4 -L ${lower(reverse(split("-", volume.name))[0])} $BLKDEV
      %{endfor}

    mounts:
      - [LABEL=state, ${var.state_dir}]
      %{if var.home_volume_size > 0}
      - [LABEL=home, /exports/home]
      %{endif}
  EOF

}
