
resource "openstack_networking_network_v2" "cluster_net" {
  name           = var.cluster_name
  admin_state_up = "true"
  segments {
    network_type = "vlan"
    physical_network = "physnet1"
  }
}

// resource "openstack_networking_subnet_v2" "cluster_subnet" {
//   name            = var.cluster_name
//   network_id      = openstack_networking_network_v2.cluster_net.id
//   cidr            = "192.168.41.0/24"
//   #dns_nameservers = ["8.8.8.8", "8.8.4.4"] #["131.111.8.42, 131.111.12.20]
//   ip_version      = 4
// }

// resource "openstack_networking_router_interface_v2" "external" {
//   router_id = data.openstack_networking_router_v2.external.id
//   subnet_id = openstack_networking_subnet_v2.cluster_subnet.id
// }