variable "cluster_name" {
    type = string
    description = "Name of cluster, used as part of domain name"
}

variable "cluster_domain_suffix" {
    type = string
    description = "Domain suffix for cluster"
    default = "invalid"
}

variable "tenant_net" {
    type = string
    description = "Name of existing tenant network"
}

variable "tenant_subnet" {
    type = string
    description = "Name of existing tenant subnet"
}

variable "storage_net" {
    type = string
    description = "Name of existing storage network"
}

variable "storage_subnet" {
    type = string
    description = "Name of existing storage subnet"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "control_node_flavor" {
    type = string
    description = "Flavor name for control name"
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> map with flavor (name) and floating IP address"
}

variable "cluster_image_id" {
    type = string
    description = "ID of default image for the cluster"
}

variable "compute_nodes" {
    type = map(string)
    description = "Mapping of compute nodename suffix -> flavor name"
}

# TODO: support
# variable "compute_images" {
#     type = map(string)
#     default = {}
#     description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
# }

variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

variable "vnic_type" {
    type = string
    description = "VNIC type, see https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#vnic_type"
    default = "normal"
}

variable "vnic_profile" {
    type = string
    description = "VNIC binding profile as json string, see https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#profile."
    default = "{}"
}

variable "volume_backed_instances" {
    description = "Whether to use volumes for root disks"
    type = bool
    default = false
}

variable "root_volume_size" {
    description = "Size of volume for root volumes if using volume backed instances, in Gb"
    type = number
    default = 40
}
