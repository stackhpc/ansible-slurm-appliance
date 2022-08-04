resource "openstack_networking_port_v2" "login" {
  for_each = toset(keys(var.login_node_flavors))

  name = "${var.cluster_name}-${each.key}"
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

resource "openstack_networking_port_v2" "nonlogin" {
  for_each = toset(concat(["control"], keys(var.compute_nodes)))

  name = "${var.cluster_name}-${each.key}"
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
  
  name = "${var.cluster_name}-control"
  image_name = lookup(var.image_names, "control", var.image_names["default"])
  flavor_name = var.control_node_flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.nonlogin["control"].id
    access_network = true
  }

  # volume-backed instance:
  block_device {
    boot_index = 0
    source_type = "image"
    uuid = data.openstack_images_image_v2.nodes[lookup(var.image_names, "control", "default")].id
    destination_type = "volume"
    volume_size = data.openstack_images_image_v2.nodes[lookup(var.image_names, "control", "default")].min_disk_gb
    delete_on_termination = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.login_node_flavors
  
  name = "${var.cluster_name}-${each.key}"
  image_name = lookup(var.image_names, each.key, var.image_names["default"])
  flavor_name = each.value
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.login[each.key].id
    access_network = true
  }

  # volume-backed instance:
  block_device {
    boot_index = 0
    source_type = "image"
    uuid = data.openstack_images_image_v2.nodes[lookup(var.image_names, each.key, "default")].id
    destination_type = "volume"
    volume_size = data.openstack_images_image_v2.nodes[lookup(var.image_names, each.key, "default")].min_disk_gb
    delete_on_termination = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.compute_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = lookup(var.image_names, each.key, var.image_names["default"])
  flavor_name = var.compute_types[each.value]
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.nonlogin[each.key].id
    access_network = true
  }

  # volume-backed instance:
  block_device {
    boot_index = 0
    source_type = "image"
    uuid = data.openstack_images_image_v2.nodes[lookup(var.image_names, each.key, "default")].id
    destination_type = "volume"
    volume_size = data.openstack_images_image_v2.nodes[lookup(var.image_names, each.key, "default")].min_disk_gb
    delete_on_termination = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}
