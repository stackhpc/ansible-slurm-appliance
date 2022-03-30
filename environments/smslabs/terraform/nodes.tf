
resource "openstack_compute_instance_v2" "control" {
  
  name = "${var.cluster_name}-control"
  image_name = var.control_node.image
  flavor_name = var.control_node.flavor
  key_pair = var.key_pair
  config_drive = true
  security_groups = ["default", "SSH"]

  network {
    uuid = data.openstack_networking_subnet_v2.cluster_subnet.network_id # ensures nodes not created till subnet created
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.login_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = each.value.image
  flavor_name = each.value.flavor
  key_pair = var.key_pair
  config_drive = true
  security_groups = ["default", "SSH"]

  network {
    uuid = data.openstack_networking_subnet_v2.cluster_subnet.network_id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.compute_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = lookup(var.compute_images, each.key, var.compute_types[each.value].image)
  flavor_name = var.compute_types[each.value].flavor
  key_pair = var.key_pair
  config_drive = true
  security_groups = ["default", "SSH"]

  network {
    uuid = data.openstack_networking_subnet_v2.cluster_subnet.network_id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}
