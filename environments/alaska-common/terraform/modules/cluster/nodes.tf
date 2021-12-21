data "openstack_images_image_v2" "control" {
    name = var.control_node.image
}

resource "openstack_compute_instance_v2" "control" {
  
  name = "${var.cluster_name}-control"
  image_name = var.control_node.image
  flavor_name = var.control_node.flavor
  key_pair = var.key_pair
  config_drive = true
  security_groups = ["default", "NFS"]

  network {
    port = data.openstack_networking_port_v2.slurmctl.id
    access_network = true
  }

  network {
    port = data.openstack_networking_port_v2.slurmctl_rdma.id
  }

  block_device {
      uuid = data.openstack_images_image_v2.control.id
      source_type  = "image"
      destination_type = "local"
      boot_index = 0
      delete_on_termination = true
  }

  # home volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = data.openstack_blockstorage_volume_v3.home.id
  }

  # slurmctld volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = data.openstack_blockstorage_volume_v3.slurmctld.id
  }

  metadata = {
    environment = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.login_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = each.value.image
  flavor_name = each.value.flavor
  key_pair = var.key_pair
  security_groups = ["default", "SSH"]

  network {
    uuid = data.openstack_networking_subnet_v2.cluster_subnet.network_id
    access_network = true
  }

  network {
    port = openstack_networking_port_v2.rdma[each.key].id
  }

  metadata = {
    environment = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.compute_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = lookup(var.compute_images, each.key, var.compute_types[each.value].image)
  flavor_name = var.compute_types[each.value].flavor
  key_pair = var.key_pair

  network {
    uuid = data.openstack_networking_subnet_v2.cluster_subnet.network_id
    access_network = true
  }

  network {
    port = openstack_networking_port_v2.rdma[each.key].id
  }

  metadata = {
    environment = var.environment_root
  }

}
