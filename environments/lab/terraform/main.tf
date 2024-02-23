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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.cluster.id
  # }

  # binding {
  #   vnic_type = var.cluster_network_vnic_type
  #   profile = jsonencode(var.cluster_network_profile)
  # }

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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.storage.id
  # }

  # binding {
  #   vnic_type = var.storage_network_vnic_type
  #   profile = jsonencode(var.storage_network_profile)
  # }

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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.control.id
  # }

  # binding {
  #   vnic_type = var.control_network_vnic_type
  #   profile = jsonencode(var.control_network_profile)
  # }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

resource "openstack_compute_instance_v2" "control" {

  name = "${var.cluster_name}-control"
  image_id = data.openstack_images_image_v2.control.id
  flavor_name = var.control_flavor
  key_pair = var.key_pair
  config_drive = true
  availability_zone = var.cluster_availability_zone

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
      uuid = data.openstack_blockstorage_volume_v3.state.id
  }

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

  user_data = <<-EOF
    #cloud-config
    bootcmd:
      - BLKDEV=$(readlink -f $(ls /dev/disk/by-id/*${substr(data.openstack_blockstorage_volume_v3.state.id, 0, 20)}* | head -n1 )); blkid -o value -s TYPE $BLKDEV ||  mke2fs -t ext4 -L state $BLKDEV
      
    mounts:
      - [LABEL=state, /var/lib/state]
  EOF
}

# --- slurm logins ---

resource "openstack_networking_port_v2" "login_cluster" {

  for_each = var.login_names

  name = each.key
  network_id = data.openstack_networking_network_v2.cluster.id
  admin_state_up = "true"

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.cluster.id
  # }

  # binding {
  #   vnic_type = var.cluster_network_vnic_type
  #   profile = jsonencode(var.cluster_network_profile)
  # }

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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.storage.id
  # }

  # binding {
  #   vnic_type = var.storage_network_vnic_type
  #   profile = jsonencode(var.storage_network_profile)
  # }

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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.control.id
  # }

  # binding {
  #   vnic_type = var.control_network_vnic_type
  #   profile = jsonencode(var.control_network_profile)
  # }

  # don't overrite os-vif adding chosen PCI device
  lifecycle {
    ignore_changes = [
      binding,
    ]
  }
}

# flavor_name = each.value
resource "openstack_compute_instance_v2" "logins" {

  for_each = var.login_names

  name = "${var.cluster_name}-${each.key}"
  image_name = var.login_image

  flavor_name = var.control_flavor
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
  port_security_enabled = "false"
  no_security_groups = "true"

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.cluster.id
  # }

  # binding {
  #   vnic_type = var.cluster_network_vnic_type
  #   profile = jsonencode(var.cluster_network_profile)
  # }

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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.storage.id
  # }

  # binding {
  #   vnic_type = var.storage_network_vnic_type
  #   profile = jsonencode(var.storage_network_profile)
  # }

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

  # fixed_ip {
  #   subnet_id = data.openstack_networking_subnet_v2.control.id
  # }

  # binding {
  #   vnic_type = var.control_network_vnic_type
  #   profile = jsonencode(var.control_network_profile)
  # }

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
  }

  network {
    port = openstack_networking_port_v2.compute_cluster[each.key].id
    access_network = true
  }

  network {
    port = openstack_networking_port_v2.compute_storage[each.key].id
  }

}

# --- floating ips ---

resource "openstack_networking_floatingip_v2" "logins" {

  for_each = var.login_names

  pool = data.openstack_networking_network_v2.external.name
  # address = var.login_ips[each.key]
}

resource "openstack_compute_floatingip_associate_v2" "logins" {
  for_each = var.login_names

  floating_ip = openstack_networking_floatingip_v2.logins[each.key].address
  instance_id = openstack_compute_instance_v2.logins[each.key].id
   # networks are zero-indexed
  fixed_ip = openstack_compute_instance_v2.logins[each.key].network.2.fixed_ip_v4

}

resource "openstack_networking_floatingip_v2" "control" {

  pool = data.openstack_networking_network_v2.external.name
  # address = var.control_ip
}

resource "openstack_compute_floatingip_associate_v2" "control" {

  floating_ip = openstack_networking_floatingip_v2.control.address
  instance_id = openstack_compute_instance_v2.control.id
   # networks are zero-indexed
  fixed_ip = openstack_compute_instance_v2.control.network.2.fixed_ip_v4
}

# --- template ---

# TODO: needs fixing for case where creation partially fails resulting in "compute.network is empty list of object"
resource "local_file" "hosts" {
  content  = templatefile("${path.module}/inventory.tpl",
                          {
                            "cluster_name": var.cluster_name
                            "cluster_slurm_name": var.cluster_slurm_name
                            "proxy_fip": openstack_networking_floatingip_v2.logins[var.proxy_name].address
                            "control": openstack_compute_instance_v2.control,
                            "logins": openstack_compute_instance_v2.logins,
                            "computes": openstack_compute_instance_v2.computes,
                          },
                          )
  filename = "../inventory/hosts"
}
