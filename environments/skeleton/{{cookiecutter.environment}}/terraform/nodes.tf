locals {
  user_data_path = "${var.environment_root}/cloud_init/${var.cluster_name}-%s.userdata.yml"
}


data "openstack_images_image_v2" "control" {
  name = var.control_node.image
}

resource "openstack_networking_port_v2" "login" {

  for_each = toset(keys(var.login_nodes))

  name = "${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}"
  network_id = data.openstack_networking_network_v2.cluster_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id
  }

  security_group_ids = [for o in data.openstack_networking_secgroup_v2.login: o.id]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_networking_port_v2" "control" {

  name = "control.${var.cluster_name}.${var.cluster_domain_suffix}"
  network_id = data.openstack_networking_network_v2.cluster_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id
  }

  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_networking_port_v2" "compute" {

  for_each = toset(keys(var.compute_nodes))

  name = "${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}"
  network_id = data.openstack_networking_network_v2.cluster_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id
  }

  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}


resource "openstack_compute_instance_v2" "control" {
  
  for_each = var.create_nodes ? toset(["control"]) : toset([])
  
  name = "control.${var.cluster_name}.${var.cluster_domain_suffix}"
  image_name = data.openstack_images_image_v2.control.name
  flavor_name = var.control_node.flavor
  key_pair = var.key_pair
  
  # root device:
  block_device {
      uuid = data.openstack_images_image_v2.control.id
      source_type  = "image"
      destination_type = "local"
      boot_index = 0
      delete_on_termination = true
  }

  # state volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = openstack_blockstorage_volume_v3.state.id
  }

  # home volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = openstack_blockstorage_volume_v3.home.id
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
    hostname: control
    fqdn: control.${var.cluster_name}.${var.cluster_domain_suffix}"
    prefer_fqdn_over_hostname: true

    fs_setup:
      - label: state
        filesystem: ext4
        device: ${var.state_volume_device_path}
        partition: auto
      - label: home
        filesystem: ext4
        device: ${var.home_volume_device_path}
        partition: auto

    mounts:
      - [LABEL=state, ${var.state_dir}]
      - [LABEL=home, /exports/home, auto, "x-systemd.required-by=nfs-server.service,x-systemd.before=nfs-server.service"]
  EOF

  lifecycle{
    ignore_changes = [
      image_name,
      ]
    }

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.create_nodes ? var.login_nodes : {}
  
  name = "${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}"
  image_name = each.value.image
  flavor_name = each.value.flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.login[each.key].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

  user_data = <<-EOF
    #cloud-config
    hostname: ${each.key}
    fqdn: ${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
    prefer_fqdn_over_hostname: true
  EOF

  lifecycle{
    ignore_changes = [
      image_name,
      ]
    }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.create_nodes ? var.compute_nodes : {}
  
  name = "${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}"
  image_name = lookup(var.compute_images, each.key, var.compute_types[each.value].image)
  flavor_name = var.compute_types[each.value].flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.compute[each.key].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

  user_data = <<-EOF
    #cloud-config
    hostname: ${each.key}
    fqdn: ${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
    prefer_fqdn_over_hostname: true
  EOF

  lifecycle{
    ignore_changes = [
      image_name,
      ]
    }

}
