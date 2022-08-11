terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

# --- slurm controller ---

resource "openstack_networking_port_v2" "control_cluster" {

  name = "control"
  network_id = data.openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster.id
  }

  binding {
    vnic_type = var.cluster_network_vnic_type
    profile = jsonencode(var.cluster_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_networking_port_v2" "control_storage" {

  name = "control"
  network_id = data.openstack_networking_network_v2.storage.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.storage.id
  }

  binding {
    vnic_type = var.storage_network_vnic_type
    profile = jsonencode(var.storage_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_networking_port_v2" "control_control" {

  name = "control"
  network_id = data.openstack_networking_network_v2.control.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.control.id
  }

  security_group_ids = [
    data.openstack_networking_secgroup_v2.default.id,
    data.openstack_networking_secgroup_v2.grafana.id,
    data.openstack_networking_secgroup_v2.deploy_ssh.id,
  ]

  binding {
    vnic_type = var.control_network_vnic_type
    profile = jsonencode(var.control_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_compute_instance_v2" "control" {

  name = "${var.cluster_name}-control"
  image_name = var.control_image
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  config_drive = true
  availability_zone = var.cluster_availability_zone

  network {
    port = openstack_networking_port_v2.control_cluster.id
  }

  network {
    port = openstack_networking_port_v2.control_storage.id
  }

  network {
    port = openstack_networking_port_v2.control_control.id
    access_network = true
  }

}

# --- slurm logins ---

resource "openstack_networking_port_v2" "login_cluster" {

  for_each = var.login_names

  name = each.key
  network_id = data.openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster.id
  }

  binding {
    vnic_type = var.cluster_network_vnic_type
    profile = jsonencode(var.cluster_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_networking_port_v2" "login_storage" {

  for_each = var.login_names

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

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_networking_port_v2" "login_control" {

  for_each = var.login_names

  name = each.key
  network_id = data.openstack_networking_network_v2.control.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.control.id
  }

  security_group_ids = [
    data.openstack_networking_secgroup_v2.default.id,
    data.openstack_networking_secgroup_v2.deploy_ssh.id,
  ]

  binding {
    vnic_type = var.control_network_vnic_type
    profile = jsonencode(var.control_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_compute_instance_v2" "logins" {

  for_each = var.login_names

  name = "${var.cluster_name}-${each.key}"
  image_name = var.login_image
  flavor_name = each.value
  key_pair = var.key_pair
  config_drive = true
  availability_zone = var.cluster_availability_zone

  network {
    port = openstack_networking_port_v2.login_cluster[each.key].id
  }

  network {
    port = openstack_networking_port_v2.login_storage[each.key].id
  }

  network {
    port = openstack_networking_port_v2.login_control[each.key].id
    access_network = true
  }

}

# --- slurm compute ---

resource "openstack_networking_port_v2" "compute_cluster" {

  for_each = var.compute_names

  name = each.key
  network_id = data.openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster.id
  }

  binding {
    vnic_type = var.cluster_network_vnic_type
    profile = jsonencode(var.cluster_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_networking_port_v2" "compute_storage" {

  for_each = var.compute_names

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

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_networking_port_v2" "compute_control" {

  for_each = var.compute_names

  name = each.key
  network_id = data.openstack_networking_network_v2.control.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.control.id
  }

  security_group_ids = [
    data.openstack_networking_secgroup_v2.default.id,
    data.openstack_networking_secgroup_v2.grafana.id,
    data.openstack_networking_secgroup_v2.deploy_ssh.id,
  ]


  binding {
    vnic_type = var.control_network_vnic_type
    profile = jsonencode(var.control_network_profile)
  }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}


resource "openstack_compute_instance_v2" "computes" {

  for_each = var.compute_names

  name = "${var.cluster_name}-${each.key}"
  image_name = lookup(var.compute_images, each.key, var.compute_types[each.value].image)
  flavor_name = var.compute_types[each.value].flavor
  key_pair = var.key_pair
  config_drive = true
  availability_zone = var.cluster_availability_zone

  network {
    port = openstack_networking_port_v2.compute_control[each.key].id
    access_network = true
  }

  network {
    port = openstack_networking_port_v2.compute_cluster[each.key].id
  }

  network {
    port = openstack_networking_port_v2.compute_storage[each.key].id
  }

}


# --- template ---

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "cluster_slurm_name": var.cluster_slurm_name
                            "control": openstack_compute_instance_v2.control,
                            "logins": openstack_compute_instance_v2.logins,
                            "computes": openstack_compute_instance_v2.computes,
                          },
                          )
  filename = "../inventory/hosts"
}
