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
    default = "slurm"
}

variable "tenant_subnet" {
    type = string
    description = "Name of existing tenant subnet"
    default = "slurm"
}

variable "storage_net" {
    type = string
    description = "Name of existing storage network"
    default = "slurm-data"
}

variable "storage_subnet" {
    type = string
    description = "Name of existing storage subnet"
    default = "slurm-data"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "control_node_flavor" {
    type = string
    description = "Flavor name for control name"
    default = "general.v1.16cpu.32gb" # defined in OpenStack Kayobe Reference Architecture v1.6
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> map with flavor (name) and floating IP address"
}

variable "cluster_image_id" {
    type = string
    description = "ID of default image for the cluster"
    default = "fa21f5a7-184a-496b-8570-62db2314eb32" # openhpc-ofed-RL9-240621-1308-96959324, v1.149
}

# variable "compute_nodes" {
#     type = map(string)
#     description = "Mapping of compute nodename suffix -> flavor name"
# }

variable "compute" {
    type = map
    description = <<-EOF
        Mapping defining compute infrastructure. Keys are names of groups. Values are a
        mapping as follows:

        Required:
            nodes: List of node names
            flavor: String flavor name
        Optional:
            image_id: Overrides variable cluster_image_id
            vnic_type: Overrides variable vnic_type
            vnic_profile: Overrides variable vnic_profile
    EOF
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
