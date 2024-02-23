data "openstack_networking_secgroup_v2" "ssh" {
  name = "ssh"
}

resource "openstack_networking_port_secgroup_associate_v2" "ssh" {

  for_each = var.login_names
  
  port_id = openstack_networking_port_v2.login_control[each.key].id
  security_group_ids = [
    data.openstack_networking_secgroup_v2.ssh.id,
  ]
}
