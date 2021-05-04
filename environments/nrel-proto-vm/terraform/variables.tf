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
    description = "Name of network to use for cluster"
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

variable "cidr" {
    type = string
    default = "192.168.42.0/24"
    description = "Range in CIDR notation for cluster subnet"
}

variable "external_network" {
  type = string
  description = "Name of pre-existing external network"
}

variable "external_router" {
  type = string
  description = "Name of pre-existing router on external network"
}

variable "provider_networks" {
  type = list(string)
  description = "Name of pre-existing networks to additionally connect to cluster instances"
  default = []
}
