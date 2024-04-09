locals {
  control_volumes = [data.openstack_blockstorage_volume_v3.state]
}

resource "openstack_networking_port_v2" "login_tenant" {

  for_each = var.login_nodes

  name = "${var.cluster_name}-${each.key}-tenant"
  network_id = data.openstack_networking_network_v2.tenant_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.tenant_subnet.id
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.cluster.id,
    openstack_networking_secgroup_v2.login.id
  ]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_networking_port_v2" "login_storage" {

  for_each = var.login_nodes

  name = "${var.cluster_name}-${each.key}"
  network_id = data.openstack_networking_network_v2.storage_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.storage_subnet.id
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.cluster.id
  ]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_networking_port_v2" "control" {

  name = "${var.cluster_name}-control"
  network_id = data.openstack_networking_network_v2.storage_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.storage_subnet.id
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.cluster.id
  ]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_compute_instance_v2" "control" {
  
  for_each = toset(["control"])
  
  name = "${var.cluster_name}-${each.key}"
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

  network {
    port = openstack_networking_port_v2.control.id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

  user_data = <<-EOF
    #cloud-config
    fqdn: ${var.cluster_name}-${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
    
    bootcmd:
      %{for volume in local.control_volumes}
      - BLKDEV=$(readlink -f $(ls /dev/disk/by-id/*${substr(volume.id, 0, 20)}* | head -n1 )); blkid -o value -s TYPE $BLKDEV ||  mke2fs -t ext4 -L ${lower(split("-", volume.name)[1])} $BLKDEV
      %{endfor}

    mounts:
      - [LABEL=state, /var/lib/state]
  EOF

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.login_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_id = var.cluster_image_id
  flavor_name = each.value.flavor
  key_pair = var.key_pair

  dynamic "block_device" {
    for_each = var.volume_backed_instances ? [1]: []
    content {
      uuid = var.cluster_image_id
      source_type  = "image"
      destination_type = "volume"
      volume_size = var.root_volume_size
      boot_index = 0
      delete_on_termination = true
    }
  }
  
  network {
    port = openstack_networking_port_v2.login_storage[each.key].id
    access_network = true # using FIP as proxyjump
  }

  network {
    port = openstack_networking_port_v2.login_tenant[each.key].id
    access_network = false
  }

  metadata = {
    environment_root = var.environment_root
  }

  user_data = <<-EOF
    #cloud-config
    fqdn: ${var.cluster_name}-${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
  EOF

}
