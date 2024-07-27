variable "compute_types" {
    type = map
    description = "Mapping defining types of compute nodes: key -> (str) name of type, value -> mapping {flavor: flavor_name image: image_name_or_id }"
}

variable "compute_names" {
    type = map(string)
    default = {}
    description = "Mapping of compute node name -> key in compute_types (Note nodenames are prefixed with cluster_name to make hostnames)"
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

variable "cluster_slurm_name" {
    type = string
    description = "Name for cluster in Slurm"
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

variable "login_ips" {
    type = map
    description = "Map of login names -> floating IP"
}

variable "login_flavor" {
    type = string
    description = "Name of instance flavor for login nodes"
}

variable "control_flavor" {
    type = string
    description = "Name of instance flavor for control node"
}

variable "control_image" {
    type = string
    description = "Name of image for compute node"
}

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}

variable "control_ip" {
    type = string
    description = "Floating IP for slurm control node"
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

variable "cluster_availability_zone" {
    type = string
    description = "Name of the availability zone to be used. Assumes there are different AZs for prod vs test vs stage."
    default = null
}
