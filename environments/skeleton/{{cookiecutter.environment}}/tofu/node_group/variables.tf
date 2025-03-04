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

variable "vnic_types" {
    type = map(string)
    default = {}
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

variable "extra_volumes" {
    description = <<-EOF
        Mapping defining additional volumes to create and attach.
        Keys are unique volume name.
        Values are a mapping with:
            size: Size of volume in GB
        **NB**: The order in /dev is not guaranteed to match the mapping
        EOF
    type = any
    default = {}
}

variable "security_group_ids" {
    type = list
}

variable "control_address" {
    description = "Name/address of control node"
    type = string
}

variable "compute_init_enable" {
    type = list(string)
    description = "Groups to activate for ansible-init compute rebuilds"
    default = []
}

variable "ignore_image_changes" {
    type = bool
    description = "Whether to ignore changes to the image_id parameter"
    default = false
}

variable "networks" {
    type = list(map(string))
    default = []
}

variable "fip_addresses" {
    type = list(string)
    description = <<-EOT
        List of addresses of floating IPs to associate with nodes,
        in same order as nodes parameter. The floating IPs must already be
        allocated to the project.
    EOT
    default = []
}

variable "fip_network" {
    type = string
    description = <<-EOT
        Name of network containing ports to attach FIPs to. Only required if multiple
        networks are defined.
    EOT
    default = ""
}

variable "match_ironic_node" {
    type = bool
    description = "Whether to launch instances on the Ironic node of the same name as each cluster node"
    default = false
}

variable "availability_zone" {
    type = string
    description = "Name of availability zone - ignored unless match_ironic_node is true"
    default = "nova"
}

variable "baremetal_nodes" {
    type = map(string)
    default = {}
}
