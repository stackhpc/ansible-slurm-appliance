variable "nodes" {
    type = list(string)
    description = "list of node names for partition"
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

variable "cluster_net_id" {
    type = string
}

variable "cluster_subnet_id" {
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

variable "volumes" {
    description = <<-EOF
        Mapping defining volumes to create and attach.
        Keys are unique volume name.
        Values are a mapping with:
            size: Size of volume in GB
        EOF
    type = any
    default = {}
}

variable "security_group_ids" {
    type = list
}
