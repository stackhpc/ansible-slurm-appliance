
data "openstack_networking_network_v2" "tenant_net" {
  name = var.tenant_net
}

data "openstack_networking_subnet_v2" "tenant_subnet" {

  name = var.tenant_subnet
}

data "openstack_networking_network_v2" "storage_net" {
  name = var.storage_net
}

data "openstack_networking_subnet_v2" "storage_subnet" {
  name = var.storage_subnet
}

# Security group to hold common rules for the cluster
resource "openstack_networking_secgroup_v2" "cluster" {
  name                 = "${ var.cluster_name }-cluster"
  description          = "Rules for the slurm cluster nodes"
  delete_default_rules = true   # Fully manage with terraform
}

# Security group to hold specific rules for the login node
resource "openstack_networking_secgroup_v2" "login" {
  name                 = "${ var.cluster_name }-login"
  description          = "Specific rules for the slurm login node"
  delete_default_rules = true   # Fully manage with terraform
}

## Allow all egress for all cluster nodes
resource "openstack_networking_secgroup_rule_v2" "slurm_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

## Allow all ingress between nodes in the cluster
resource "openstack_networking_secgroup_rule_v2" "slurm_internal_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.cluster.id
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

## Allow ingress on port 22 (SSH) from anywhere for the login nodes
resource "openstack_networking_secgroup_rule_v2" "slurm_login_ssh_ingress_ssh_v4" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.login.id
}

## Allow ingress on port 443 (HTTPS) from anywhere for the login nodes
resource "openstack_networking_secgroup_rule_v2" "slurm_login_https_ingress_v4" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.login.id
}

## Allow ingress on port 80 (HTTP) from anywhere for the login nodes
resource "openstack_networking_secgroup_rule_v2" "slurm_login_http_ingress_v4" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.login.id
}

resource "openstack_networking_floatingip_associate_v2" "login" {
  for_each = var.login_nodes
  
  floating_ip = each.value.fip
  port_id = openstack_networking_port_v2.login_tenant[each.key].id
}
