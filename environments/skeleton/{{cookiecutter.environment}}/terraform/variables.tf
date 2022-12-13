variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_net" {
    type = string
    description = "Name of existing cluster network"
}

variable "cluster_subnet" {
    type = string
    description = "Name of existing cluster subnet"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "control_node" {
    type = map
    description = "Mapping {flavor: flavor_name, image: image_name_or_id }"
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> mapping  {flavor: flavor_name, image: image_name_or_id }"
}

variable "compute_types" {
    type = map
    description = "Mapping defining types of compute nodes: key -> (str) name of type, value -> mapping {flavor: flavor_name, image: image_name_or_id }"
}

variable "compute_nodes" {
    type = map(string)
    description = "Mapping of compute nodename suffix -> key in compute_types"
}

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}

variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

variable "state_volume_device_path" {
    type = string
    description = "Path to block device for state"
    default = "/dev/sdb"
}

variable "home_volume_device_path" {
    type = string
    description = "Path to block device name for home directories"
    default = "/dev/sdc"
}

variable "state_dir" {
    type = string
    description = "Path to state directory on control node"
    default = "/var/lib/state"
}

variable "state_volume_size" {
    type = number
    description = "Size of state volume on control node, in GB"
    default = 150 # GB
}

variable "home_volume_size" {
    type = number
    description = "Size of state volume on control node, in GB"
    default = 100 # GB
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

variable "login_security_groups" {
    type = list(string)
    description = "Name of preexisting security groups to apply to login nodes"
    default = [
        "default",  # allow all in-cluster services
        "SSH",      # access via ssh
        "HTTPS",    # access OpenOndemand
    ]
}

variable "nonlogin_security_groups" {
    type = list(string)
    description = "Name of preexisting security groups to apply to non-login nodes"
    default = [
        "default",  # allow all in-cluster services
    ]
}

variable "create_nodes" {
    description = "Whether to create nodes (servers) or just ports and other infra"
    type = bool # can't use bool as want to pass from command-line
    default = true
}
