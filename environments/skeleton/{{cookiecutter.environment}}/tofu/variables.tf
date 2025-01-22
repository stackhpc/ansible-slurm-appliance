variable "cluster_name" {
    type = string
    description = "Name of cluster, used as part of domain name"
}

variable "cluster_domain_suffix" {
    type = string
    description = "Domain suffix for cluster"
    default = "internal"
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

variable "control_node_flavor" {
    type = string
    description = "Flavor name for control name"
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> (str) flavor name"
}

variable "cluster_image_id" {
    type = string
    description = "ID of default image for the cluster"
}

variable "compute" {
    type = any
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
            compute_init_enable: Toggles compute-init rebuild (see compute-init role docs)
            ignore_image_changes: Ignore changes to the image_id parameter (see docs/experimental/compute-init.md)
            volume_backed_instances: Overrides variable volume_backed_instances
            root_volume_size: Overrides variable root_volume_size
            extra_volumes: Mapping defining additional volumes to create and attach
                           Keys are unique volume name.
                           Values are a mapping with:
                                size: Size of volume in GB
                           **NB**: The order in /dev is not guaranteed to match the mapping
    EOF
}

variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
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

variable "state_volume_type" {
    type = string
    description = "Type of state volume, if not default type"
    default = null
}

variable "home_volume_size" {
    type = number
    description = "Size of state volume on control node, in GB"
    default = 100 # GB, 0 means no home volume
}

variable "home_volume_type" {
    type = string
    default = null
    description = "Type of home volume, if not default type"
}

variable "vnic_type" {
    type = string
    description = "Default VNIC type, see https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#vnic_type"
    default = "normal"
}

variable "vnic_profile" {
    type = string
    description = "Default VNIC binding profile as json string, see https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#profile."
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

variable "inventory_secrets_path" {
  description = "Path to inventory secrets.yml file. Default is standard cookiecutter location."
  type = string
  default = ""
}

data "external" "inventory_secrets" {
  program = ["${path.module}/read-inventory-secrets.py"]

  query = {
    path = var.inventory_secrets_path == "" ? "${path.module}/../inventory/group_vars/all/secrets.yml" : var.inventory_secrets_path
  }
}

locals {
    k3s_token = data.external.inventory_secrets.result["vault_k3s_token"]
}
