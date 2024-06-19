variable "nodes" {
    type = list(string)
    description = "list of node names for partition"
    # TODO: a variable like "nodenames_as_hypervisor" which when set, for this group
    # will add availability_zone = "nova::${each.key}" where 'each' is nodes loop,
    # i.e. nodes map 1:1 to hypervisors
    # more flexibily, we could just take a list of hypervisors as an optional indexed list?
    # not sure we actually need that though
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
    default = "invalid"
}

variable "storage_net_id" {
    type = string
}

variable "storage_subnet_id" {
    type = string
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "image_id" {
    type = string
    description = "ID of image for the partition"
}

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

variable "security_group_ids" {
    type = list
}
