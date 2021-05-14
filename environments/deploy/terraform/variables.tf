variable "compute_names" {
    type = map(string)
    default = {}
    description = "Mapping of names -> flavor type for compute nodes (Note hostnames will be be prefixed with cluster_name)"
}

variable "proxy_name" {
    type = string
    description = "Name from login_names keys defining login node to use for proxy"
}

variable "login_names" {
  type = map(string)
  default = {}
  description = "Mapping of names -> flavor type for login nodes (Note hostnames will be prefixed with cluster_name)"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_network" {
    type = string
    description = "Name of pre-existing vnet to use for cluster"
}

variable "cluster_subnet" {
    type = string
    description = "Name of subnet to use for cluster"
}

variable "cluster_network_vnic_type" {
    type = string
    default = "direct"
    description = "VNIC type for ports on this network, see `binding` in docs for openstack_networking_port_v2"
}

variable "cluster_network_profile" {
    type = map
    description = "Custom binding information, as terraform map"
    default = {
        capabilities = ["switchdev"]
    }
}

variable "storage_network" {
    type = string
    description = "Name of pre-existing external network"
}

variable "storage_subnet" {
    type = string
    description = "Name of pre-existing storage network"
}

variable "storage_network_vnic_type" {
    type = string
    default = "direct"
    description = "VNIC type for ports on this network, see `binding` in docs for openstack_networking_port_v2"
}

variable "storage_network_profile" {
    type = map
    description = "Custom binding information, as terraform map"
    default = {
        capabilities = ["switchdev"]
    }
}

variable "control_network" {
    type = string
    description = "Name of pre-existing vnet to use for cluster"
}

variable "control_subnet" {
    type = string
    description = "Name of subnet to use for cluster"
}

variable "control_network_vnic_type" {
    type = string
    default = "normal"
    description = "VNIC type for ports on this network, see `binding` in docs for openstack_networking_port_v2"
}

variable "control_network_profile" {
    type = map
    description = "Custom binding information, as terraform map"
    default = {}
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "login_image" {
    type = string
    description = "Name of image for login node(s)"
}

variable "control_flavor" {
    type = string
    description = "Name of instance flavor for control node"
}

variable "control_image" {
    type = string
    description = "Name of image for compute node"
}

variable "compute_image" {
    type = string
    description = "Name of image for compute node(s)"
}

variable "cluster_network_cidr" {
    type = string
    default = "192.168.42.0/24"
    description = "Range in CIDR notation for cluster subnet"
}

variable "external_network" {
  type = string
  description = "Name of pre-existing external network"
}
