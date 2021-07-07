
resource "openstack_compute_instance_v2" "control" {
  
  name = "${var.cluster_name}-control"
  image_name = var.control_node.image
  flavor_name = var.control_node.flavor
  key_pair = var.key_pair
  config_drive = true

  network {
    uuid = openstack_networking_network_v2.cluster_net.id
  }

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.login_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = each.value.image
  flavor_name = each.value.flavor
  key_pair = var.key_pair
  config_drive = true

  network {
    uuid = openstack_networking_network_v2.cluster_net.id
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.compute_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = var.compute_types[each.key].image
  flavor_name = var.compute_types[each.key].flavor
  key_pair = var.key_pair
  config_drive = true

  network {
    uuid = openstack_networking_network_v2.cluster_net.id
  }

}
