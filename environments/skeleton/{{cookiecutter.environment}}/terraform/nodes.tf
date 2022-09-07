resource "openstack_networking_port_v2" "login" {
  for_each = toset(keys(var.login_nodes))

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
  image_name = var.control_node.image
  flavor_name = var.control_node.flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.nonlogin["control"].id
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
  
  network {
    port = openstack_networking_port_v2.login[each.key].id
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
  
  network {
    port = openstack_networking_port_v2.nonlogin[each.key].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

  user_data = fileexists("${var.environment_root}/userdata/compute.userdata.yml") ? file("${var.environment_root}/userdata/compute.userdata.yml") : null

}
