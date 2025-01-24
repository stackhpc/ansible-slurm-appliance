locals {
  all_compute_volumes = {for v in setproduct(var.nodes, keys(var.extra_volumes)): "${v[0]}-${v[1]}" => {"node" = v[0], "volume" = v[1]}}
  # e.g. with
  # var.nodes = ["compute-0", "compute-1"]
  # var.extra_volumes = {
  #     "vol-a" = {size = 10},
  #     "vol-b" = {size = 20}
  # }
  # this is a mapping with
  # keys "compute-0-vol-a", "compute-0-vol-b" ...
  # values which are a mapping e.g. {"node"="compute-0", "volume"="vol-a"}

  # Workaround for lifecycle meta-argument only taking static values
  compute_instances = var.ignore_image_changes ? openstack_compute_instance_v2.compute_fixed_image : openstack_compute_instance_v2.compute
}

resource "openstack_blockstorage_volume_v3" "compute" {

    for_each = local.all_compute_volumes

    name = "${var.cluster_name}-${each.key}"
    description = "Compute node ${each.value.node} volume ${each.value.volume}"
    size = var.extra_volumes[each.value.volume].size
}

resource "openstack_compute_volume_attach_v2" "compute" {

  for_each = local.all_compute_volumes

  instance_id = local.compute_instances["${each.value.node}"].id
  volume_id  = openstack_blockstorage_volume_v3.compute["${each.key}"].id
}

resource "openstack_networking_port_v2" "compute" {

  for_each = {for item in setproduct(var.nodes, var.networks):
    "${item[0]}-${item[1].network}" => item[1]
  }

  name = "${var.cluster_name}-${each.key}"
  network_id = data.openstack_networking_network_v2.network[each.value.network].id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.subnet[each.value.network].id
  }

  security_group_ids = var.security_group_ids

  binding {
    vnic_type = lookup(var.vnic_types, each.value.network, "normal")
    profile = lookup(var.vnic_profiles, each.value.network, "{}")
  }
}

resource "openstack_compute_instance_v2" "compute_fixed_image" {

  for_each = var.ignore_image_changes ? toset(var.nodes) : []

  name = "${var.cluster_name}-${each.key}"
  image_id = var.image_id
  flavor_name = var.flavor
  key_pair = var.key_pair

  dynamic "block_device" {
    for_each = var.volume_backed_instances ? [1]: []
    content {
      uuid = var.image_id
      source_type  = "image"
      destination_type = "volume"
      volume_size = var.root_volume_size
      boot_index = 0
      delete_on_termination = true
    }
  }

  dynamic "network" {
    for_each = {for net in var.networks: net.network => net}
    content {
      port = openstack_networking_port_v2.compute["${each.key}-${network.key}"].id
      access_network = network.key == var.networks[0].network
    }
  }

  metadata = merge(
    {
        environment_root = var.environment_root
        k3s_token          = var.k3s_token
        control_address    = var.control_address
    },
    {for e in var.compute_init_enable: e => true}
  )

  user_data = <<-EOF
    #cloud-config
    fqdn: ${var.cluster_name}-${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
  EOF

  lifecycle {
    ignore_changes = [
      image_id,
    ]
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.ignore_image_changes ? [] : toset(var.nodes)
  
  name = "${var.cluster_name}-${each.key}"
  image_id = var.image_id
  flavor_name = var.flavor
  key_pair = var.key_pair

  dynamic "block_device" {
    for_each = var.volume_backed_instances ? [1]: []
    content {
      uuid = var.image_id
      source_type  = "image"
      destination_type = "volume"
      volume_size = var.root_volume_size
      boot_index = 0
      delete_on_termination = true
    }
  }
  
  dynamic "network" {
    for_each = {for net in var.networks: net.network => net}
    content {
      port = openstack_networking_port_v2.compute["${each.key}-${network.key}"].id
      access_network = network.key == var.networks[0].network
    }
  }

  metadata = merge(
    {
        environment_root = var.environment_root
        k3s_token          = var.k3s_token
        control_address    = var.control_address
        # TODO: set k3s_subnet from access_network
     },
    {for e in var.compute_init_enable: e => true}
  )

  user_data = <<-EOF
    #cloud-config
    fqdn: ${var.cluster_name}-${each.key}.${var.cluster_name}.${var.cluster_domain_suffix}
  EOF

}

output "compute_instances" {
    value = local.compute_instances
}
