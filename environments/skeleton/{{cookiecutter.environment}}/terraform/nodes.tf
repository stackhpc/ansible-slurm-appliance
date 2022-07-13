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

data "external" "secrets" {

  program = ["${path.module}/run_ansible.sh", "${path.root}/../../../ansible/output_secrets.yml"]
}

data "template_cloudinit_config" "compute" {
  # NB: The alternative approach of templating in cloud-init using  `## template: jinja` passing the control name as instance metadata didn't work.
  gzip          = true
  base64_encode = true

  part {
    filename = "user-data"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/compute-init.tpl",
      {
        control_address = openstack_compute_instance_v2.control.name,
        munge_key = data.external.secrets.result.openhpc_munge_key_b64,
        clouds_yaml = data.external.secrets.result.clouds_yaml,
      }
    )
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

  user_data = data.template_cloudinit_config.compute.rendered

}
