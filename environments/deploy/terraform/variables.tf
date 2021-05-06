variable "compute_names" {
    type = list(string)
    default = ["compute-0", "compute-1"]
    description = "A list of hostnames for the compute nodes (will be prefixed by cluster_name)"
}

variable "login_names" {
  type = list(string)
  default = ["login-0", "login-1"]
  description = "A list of hostnames for the login nodes (will be prefixed by cluster_name)"
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

variable "login_flavor" {
    type = string
    description = "Name of instance flavor for login node(s)"
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

variable "compute_flavor" {
    type = string
    description = "Name of instance flavor for compute node(s)"
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
