# NB: Only variables which may be set directly on the compute group are
# have descriptions here (and defaults if optional) - others are just passed in

variable "nodes" {
    type = list(string)
    description = "List of node names for this compute group"
}

variable "flavor" {
    type = string
    description = "Name of flavor for partition"
}

variable "cluster_name" {
    type = string
}

variable "cluster_domain_suffix" {
    type = string
}

variable "cluster_net_id" {
    type = string
}

variable "cluster_subnet_id" {
    type = string
}

variable "key_pair" {
    type = string
}

variable "image_id" {
    type = string
    description = "ID of image for this compute node group"
}

variable "environment_root" {
    type = string
}

variable "vnic_type" {
    type = string
    description = "VNIC type for this compute group, see https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#vnic_type"
    default = "normal"
}

variable "vnic_profile" {
    type = string
    description = "VNIC binding profile for this compute group as json string, see https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#profile."
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

variable "security_group_ids" {
    type = list
}

variable "k3s_token" {
    type = string
}

variable "k3s_server" {
    type = string
}

variable "match_ironic_node" {
    description = "Whether to launch instances on the Ironic node of the same name as this cluster node"
    type = bool
    default = false

}

variable availability_zone {
    description = "Name of availability zone - ignored unless match_ironic_node is true"
    type = string
    default = "nova"
}

variable "baremetal_nodes" {
    type = map(string)
}
