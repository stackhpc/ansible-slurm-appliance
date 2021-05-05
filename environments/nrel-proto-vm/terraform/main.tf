terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}


data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

data "openstack_networking_network_v2" "storage" {
  name = var.storage_network
}

data "openstack_networking_subnet_v2" "storage" {
  name = var.storage_subnet
}

resource "openstack_networking_network_v2" "cluster" {
  name = var.cluster_network
  admin_state_up = "true"
  segments {
    network_type = var.cluster_network_type
  }
}

resource "openstack_networking_subnet_v2" "cluster" {

  name = var.cluster_network
  network_id = openstack_networking_network_v2.cluster.id
  cidr = var.cluster_network_cidr
  ip_version = 4
}

resource "openstack_networking_port_v2" "control_cluster" {

  name = "control-${var.cluster_network}"
  network_id = openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.cluster.id
  }

  binding {
    vnic_type = var.cluster_network_vnic_type
    profile = jsonencode(var.cluster_network_profile)
  }
}

resource "openstack_networking_port_v2" "control_storage" {

  name = "control-${var.storage_network}"
  network_id = data.openstack_networking_network_v2.storage.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.storage.id
  }

  binding {
    vnic_type = var.storage_network_vnic_type
    profile = jsonencode(var.storage_network_profile)
  }
}

resource "openstack_compute_instance_v2" "control" {
  
  name = "${var.cluster_name}-control"
  image_name = var.control_image
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.control_cluster.id
  }
  
  network {
    port = openstack_networking_port_v2.control_storage.id
  }

}

resource "openstack_networking_port_v2" "login_cluster" {

  for_each = toset(var.login_names)

  #name = "${each.key}-${var.cluster_network}"
  name = each.key
  network_id = openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.cluster.id
  }

  binding {
    vnic_type = var.cluster_network_vnic_type
    profile = jsonencode(var.cluster_network_profile)
  }
}

resource "openstack_networking_port_v2" "login_storage" {

  for_each = toset(var.login_names)

  name = each.key
  network_id = data.openstack_networking_network_v2.storage.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.storage.id
  }

  binding {
    vnic_type = var.storage_network_vnic_type
    profile = jsonencode(var.storage_network_profile)
  }
}

resource "openstack_compute_instance_v2" "logins" {

  for_each = toset(var.login_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.login_image
  flavor_name = var.login_flavor
  key_pair = var.key_pair

  network {
    port = openstack_networking_port_v2.login_cluster[each.key].id
  }
  
  network {
    port = openstack_networking_port_v2.login_storage[each.key].id
  }

}

resource "openstack_networking_port_v2" "compute_cluster" {

  for_each = toset(var.compute_names)

  name = each.key
  network_id = openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.cluster.id
  }

  binding {
    vnic_type = var.cluster_network_vnic_type
    profile = jsonencode(var.cluster_network_profile)
  }
}

resource "openstack_networking_port_v2" "compute_storage" {

  for_each = toset(var.compute_names)

  name = each.key
  network_id = data.openstack_networking_network_v2.storage.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.storage.id
  }

  binding {
    vnic_type = var.storage_network_vnic_type
    profile = jsonencode(var.storage_network_profile)
  }
}


resource "openstack_compute_instance_v2" "computes" {

  for_each = toset(var.compute_names)

  name = "${var.cluster_name}-${each.value}"
  image_name = var.compute_image
  flavor_name = var.compute_flavor
  key_pair = var.key_pair

  network {
    port = openstack_networking_port_v2.compute_cluster[each.key].id
  }
  
  network {
    port = openstack_networking_port_v2.compute_storage[each.key].id
  }

}

data "openstack_networking_router_v2" "external" {
  name = var.external_router
}

resource "openstack_networking_router_interface_v2" "cluster" {
  router_id = data.openstack_networking_router_v2.external.id
  subnet_id = openstack_networking_subnet_v2.cluster.id
}

resource "openstack_networking_floatingip_v2" "logins" {

  for_each = toset(var.login_names)

  pool = data.openstack_networking_network_v2.external.name
}

resource "openstack_compute_floatingip_associate_v2" "logins" {
  for_each = toset(var.login_names)

  floating_ip = openstack_networking_floatingip_v2.logins[each.key].address
  instance_id = openstack_compute_instance_v2.logins[each.key].id
}

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "control": openstack_compute_instance_v2.control,
                            "logins": openstack_compute_instance_v2.logins,
                            "computes": openstack_compute_instance_v2.computes,
                          },
                          )
  filename = "../inventory/hosts"
}
