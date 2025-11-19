locals {
  all_compute_volumes = { for v in setproduct(var.nodes, keys(var.extra_volumes)) : "${v[0]}-${v[1]}" => { "node" = v[0], "volume" = v[1] } }
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

  # Define fully qualified nodenames here to avoid repetition
  fqdns = {
    for n in var.nodes : n => templatestring(
      var.nodename_template,
      {
        node                  = n,
        cluster_name          = var.cluster_name,
        cluster_domain_suffix = var.cluster_domain_suffix,
        environment_name      = basename(var.environment_root)
      }
    )
  }
  # Map node names to floating IPs from the list var.fip_addresses by index
  nodegroup_fips = {
    for idx, n in var.nodes :
    n => length(var.fip_addresses) > idx ? var.fip_addresses[idx] : ""
  }

  baremetal_az = var.availability_zone != null ? var.availability_zone : "nova"
}

resource "openstack_blockstorage_volume_v3" "compute" {

  for_each = local.all_compute_volumes

  name        = "${var.cluster_name}-${each.key}"
  description = "Compute node ${each.value.node} volume ${each.value.volume}"
  size        = var.extra_volumes[each.value.volume].size
  volume_type = var.extra_volumes[each.value.volume].volume_type
}

resource "openstack_compute_volume_attach_v2" "compute" {

  for_each = local.all_compute_volumes

  instance_id = local.compute_instances[each.value.node].id
  volume_id   = openstack_blockstorage_volume_v3.compute[each.key].id
}

resource "openstack_networking_port_v2" "compute" {

  for_each = { for item in setproduct(var.nodes, var.networks) :
    "${item[0]}-${item[1].network}" => {
      node_idx = index(var.nodes, item[0])
      net      = item[1]
    }
  }

  name           = "${var.cluster_name}-${each.key}"
  network_id     = data.openstack_networking_network_v2.network[each.value.net.network].id
  admin_state_up = "true"

  fixed_ip {
    subnet_id  = data.openstack_networking_subnet_v2.subnet[each.value.net.network].id
    ip_address = try(var.ip_addresses[each.value.net.network][each.value.node_idx], null)
  }

  no_security_groups = lookup(each.value.net, "no_security_groups", false)
  security_group_ids = lookup(each.value.net, "no_security_groups", false) ? [] : var.security_group_ids

  binding {
    vnic_type = lookup(var.vnic_types, each.value.net.network, "normal")
  }

  lifecycle {
    ignore_changes = [
      binding,          # fixes running as admin
      extra_dhcp_option # required for networking-mlnx neutron plugin
    ]
  }
}

resource "openstack_compute_instance_v2" "compute_fixed_image" {

  for_each = var.ignore_image_changes ? toset(var.nodes) : []

  name        = split(".", local.fqdns[each.key])[0]
  image_id    = var.image_id
  flavor_name = var.flavor
  key_pair    = var.key_pair

  dynamic "block_device" {
    for_each = var.volume_backed_instances ? [1] : []
    content {
      uuid                  = var.image_id
      source_type           = "image"
      destination_type      = "volume"
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      boot_index            = 0
      delete_on_termination = true
    }
  }

  dynamic "network" {
    for_each = { for net in var.networks : net.network => net }
    content {
      port           = openstack_networking_port_v2.compute["${each.key}-${network.key}"].id
      access_network = network.key == var.networks[0].network
    }
  }

  dynamic "scheduler_hints" {
    for_each = var.server_group_id != null ? [true] : []
    content {
      group = var.server_group_id
    }
  }

  metadata = merge(
    {
      environment_root = var.environment_root
      control_address  = var.control_address
      access_ip        = openstack_networking_port_v2.compute["${each.key}-${var.networks[0].network}"].all_fixed_ips[0]
      gateway_ip       = var.gateway_ip
    },
    { for e in var.compute_init_enable : e => true }
  )

  user_data = <<-EOF
    #cloud-config
    fqdn: ${local.fqdns[each.key]}%{if var.additional_cloud_config != ""}


    ${templatestring(var.additional_cloud_config, var.additional_cloud_config_vars)}
    %{endif}
  EOF

  availability_zone = var.match_ironic_node ? "${local.baremetal_az}::${var.baremetal_nodes[each.key]}" : var.availability_zone

  config_drive = var.config_drive

  lifecycle {
    ignore_changes = [
      image_id,
    ]
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.ignore_image_changes ? [] : toset(var.nodes)

  name        = split(".", local.fqdns[each.key])[0]
  image_id    = var.image_id
  flavor_name = var.flavor
  key_pair    = var.key_pair

  dynamic "block_device" {
    for_each = var.volume_backed_instances ? [1] : []
    content {
      uuid                  = var.image_id
      source_type           = "image"
      destination_type      = "volume"
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      boot_index            = 0
      delete_on_termination = true
    }
  }

  dynamic "network" {
    for_each = { for net in var.networks : net.network => net }
    content {
      port           = openstack_networking_port_v2.compute["${each.key}-${network.key}"].id
      access_network = network.key == var.networks[0].network
    }
  }

  dynamic "scheduler_hints" {
    for_each = var.server_group_id != null ? [true] : []
    content {
      group = var.server_group_id
    }
  }

  metadata = merge(
    {
      environment_root = var.environment_root
      control_address  = var.control_address
      access_ip        = openstack_networking_port_v2.compute["${each.key}-${var.networks[0].network}"].all_fixed_ips[0]
      gateway_ip       = var.gateway_ip
    },
    { for e in var.compute_init_enable : e => true }
  )

  user_data = <<-EOF
    #cloud-config
    fqdn: ${local.fqdns[each.key]}

    %{if var.additional_cloud_config != ""}
    ${templatestring(var.additional_cloud_config, var.additional_cloud_config_vars)}
    %{endif}
  EOF

  availability_zone = var.match_ironic_node ? "${local.baremetal_az}::${var.baremetal_nodes[each.key]}" : var.availability_zone

  config_drive = var.config_drive

}

resource "openstack_networking_floatingip_associate_v2" "fip" {
  for_each = { for idx in range(length(var.fip_addresses)) : var.nodes[idx] => var.fip_addresses[idx] } # zip, fip_addresses can be shorter

  floating_ip = each.value
  port_id     = openstack_networking_port_v2.compute["${each.key}-${length(var.networks) == 1 ? var.networks[0].network : var.fip_network}"].id

}

output "compute_instances" {
  value = local.compute_instances
}

output "image_id" {
  value = var.image_id
}

output "fqdns" {
  value = local.fqdns
}

output "nodegroup_fips" {
  value = local.nodegroup_fips
}
