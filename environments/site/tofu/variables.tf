variable "cluster_name" {
  type        = string
  description = "Name of cluster, used as part of domain name"
}

variable "cluster_domain_suffix" {
  type        = string
  description = "Domain suffix for cluster"
  default     = "internal"
}

variable "cluster_networks" {
  type        = list(map(string))
  description = <<-EOT
        List of mappings defining networks. Mapping key/values:
            network: Required. Name of existing network
            subnet: Required. Name of existing subnet
            no_security_groups: Optional. Bool (default: false). Disable security groups
    EOT
}

variable "key_pair" {
  type        = string
  description = "Name of an existing keypair in OpenStack"
}

variable "control_ip_addresses" {
  type        = map(string)
  description = <<-EOT
        Mapping of fixed IP addresses for control node, keyed by network name.
        For any networks not specified here the cloud will select an address.

        NB: Changing IP addresses after deployment may hit terraform provider bugs.
    EOT
  default     = {}
  validation {
    # check all keys are network names in cluster_networks
    condition     = length(setsubtract(keys(var.control_ip_addresses), var.cluster_networks[*].network)) == 0
    error_message = "Keys in var.control_ip_addresses must match network names in var.cluster_networks"
  }
}

variable "control_node_flavor" {
  type        = string
  description = "Flavor name for control node"
}

variable "login" {
  default     = {}
  description = <<-EOF
        Mapping defining homogenous groups of login nodes. Multiple groups may
        be useful for e.g. separating nodes for ssh and Open Ondemand usage, or
        to define login nodes with different capabilities such as high-memory.

        Keys are names of groups.
        Values are a mapping as follows:

        Required:
            nodes: List of node names
            flavor: String flavor name
        Optional:
            image_id: Overrides variable cluster_image_id
            extra_networks: List of mappings in same format as cluster_networks
            vnic_types: Overrides variable vnic_types
            volume_backed_instances: Overrides variable volume_backed_instances
            root_volume_size: Overrides variable root_volume_size
            extra_volumes: Mapping defining additional volumes to create and attach
                           Keys are unique volume name.
                           Values are a mapping with:
                                size: Size of volume in GB
                                volume_type: Optional. Type of volume, or cloud default
                           **NB**: The order in /dev is not guaranteed to match the mapping
            fip_addresses: List of addresses of floating IPs to associate with
                           nodes, in the same order as nodes parameter. The
                           floating IPs must already be allocated to the project.
            fip_network: Name of network containing ports to attach FIPs to. Only
                        required if multiple networks are defined.
            ip_addresses: Mapping of list of fixed IP addresses for nodes, keyed
                          by network name, in same order as nodes parameter.
                          For any networks not specified here the cloud will
                          select addresses.
            match_ironic_node: Set true to launch instances on the Ironic node of the same name as each cluster node
            availability_zone: Name of availability zone. If undefined, defaults to 'nova' 
                               if match_ironic_node is true, defered to OpenStack otherwise
            gateway_ip: Address to add default route via
            nodename_template: Overrides variable cluster_nodename_template
    EOF

  type = any
}

variable "cluster_image_id" {
  type        = string
  description = "ID of default image for the cluster"
}

variable "compute" {
  default     = {}
  description = <<-EOF
        Mapping defining homogenous groups of compute nodes. Groups are used
        in Slurm partition definitions.

        Keys are names of groups.
        Values are a mapping as follows:

        Required:
            nodes: List of node names
            flavor: String flavor name
        Optional:
            image_id: Overrides variable cluster_image_id
            extra_networks: List of mappings in same format as cluster_networks
            vnic_types: Overrides variable vnic_types
            compute_init_enable: Toggles compute-init rebuild (see compute-init role docs)
            ignore_image_changes: Ignore changes to the image_id parameter (see docs/experimental/compute-init.md)
            volume_backed_instances: Overrides variable volume_backed_instances
            root_volume_size: Overrides variable root_volume_size
            extra_volumes: Mapping defining additional volumes to create and attach
                           Keys are unique volume name.
                           Values are a mapping with:
                                size: Size of volume in GB
                                volume_type: Optional. Type of volume, or cloud default
                           **NB**: The order in /dev is not guaranteed to match the mapping
            ip_addresses: Mapping of list of fixed IP addresses for nodes, keyed
                          by network name, in same order as nodes parameter.
                          For any networks not specified here the cloud will
                          select addresses.
            match_ironic_node: Set true to launch instances on the Ironic node of the same name as each cluster node
            availability_zone: Name of availability zone. If undefined, defaults to 'nova'
                               if match_ironic_node is true, defered to OpenStack otherwise
            gateway_ip: Address to add default route via
            nodename_template: Overrides variable cluster_nodename_template

        Nodes are added to the following inventory groups:
        - $group_name
        - $cluster_name + '_' + $group_name - this is used for the stackhpc.openhpc role
        - 'compute'
    EOF

  type = any # can't do any better; TF type constraints can't cope with heterogeneous inner mappings
}

# tflint-ignore: terraform_typed_variables
variable "additional_nodegroups" {
  default     = {}
  description = <<-EOF
        Mapping defining homogenous groups of nodes for arbitrary purposes.
        These nodes are not in the compute or login inventory groups so they
        will not run slurmd.

        Keys are names of groups.
        Values are a mapping as for the "login" variable, with the addition of
        the optional entry:
        
            security_group_ids: List of strings giving IDs of security groups
                                to apply. If not specified the groups from the
                                variable nonlogin_security_groups are applied.

        Nodes are added to the following inventory groups:
        - $group_name
        - $cluster_name + '_' + $group_name
        - 'additional'
    EOF
}

variable "environment_root" {
  type        = string
  description = "Path to environment root, automatically set by activate script"
}

variable "state_dir" {
  type        = string
  description = "Path to state directory on control node"
  default     = "/var/lib/state"
}

variable "state_volume_size" {
  type        = number
  description = "Size of state volume on control node, in GB"
  default     = 150 # GB
}

variable "state_volume_type" {
  type        = string
  description = "Type of state volume, if not default type"
  default     = null
}

variable "state_volume_provisioning" {
  type        = string
  default     = "manage"
  description = <<-EOT
        How to manage the state volume. Valid values are:
            "manage": (Default) OpenTofu will create a volume "$cluster_name-state"
                      and delete it when the cluster is destroyed. A volume
                      with this name must not already exist. Use for demo and
                      dev environments.
            "attach": A single volume named "$cluster_name-state" must already
                      exist. It is not managed by OpenTofu so e.g. is left
                      intact if the cluster is destroyed. Use for production
                      environments.
        EOT
  validation {
    condition     = contains(["manage", "attach"], var.state_volume_provisioning)
    error_message = <<-EOT
        home_volume_provisioning must be "manage" or "attach"
    EOT
  }
}

variable "home_volume_size" {
  type        = number
  description = "Size of state volume on control node, in GB."
  default     = 100
  validation {
    condition     = var.home_volume_provisioning == "manage" ? var.home_volume_size > 0 : true
    error_message = <<-EOT
            home_volume_size must be > 0 when var.home_volume_provisioning == "manage"
        EOT
  }
}

variable "home_volume_type" {
  type        = string
  default     = null
  description = "Type of home volume, if not default type"
}

variable "home_volume_provisioning" {
  type        = string
  default     = "manage"
  description = <<-EOT
        How to manage the home volume. Valid values are:
            "manage": (Default) OpenTofu will create a volume "$cluster_name-home"
                      and delete it when the cluster is destroyed. A volume
                      with this name must not already exist. Use for demo and
                      dev environments.
            "attach": A single volume named "$cluster_name-home" must already
                      exist. It is not managed by OpenTofu so e.g. is left
                      intact if the cluster is destroyed. Use for production
                      environments.
            "none":   No home volume is used. Use if /home is provided by
                      a parallel filesystem, e.g. manila.
        EOT
  validation {
    condition     = contains(["manage", "attach", "none"], var.home_volume_provisioning)
    error_message = <<-EOT
        home_volume_provisioning must be one of "manage", "attach" or "none"
    EOT
  }
}

variable "vnic_types" {
  type        = map(string)
  description = <<-EOT
        Default VNIC types, keyed by network name. See https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2#vnic_type
        If not given this defaults to the "normal" type.
    EOT
  default     = {}
}

variable "login_security_groups" {
  type        = list(string)
  description = "Name of preexisting security groups to apply to login nodes"
  default = [
    "default", # allow all in-cluster services
    "SSH",     # access via ssh
    "HTTPS",   # access OpenOndemand
  ]
}

variable "nonlogin_security_groups" {
  type        = list(string)
  description = "Name of preexisting security groups to apply to non-login nodes"
  default = [
    "default", # allow all in-cluster services
  ]
}

variable "volume_backed_instances" {
  description = "Whether to use volumes for root disks"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of volume for root volumes if using volume backed instances, in Gb"
  type        = number
  default     = 40
}

variable "root_volume_type" {
  description = "Type of root volume, if using volume backed instances. If unset, the target cloud default volume type is used."
  type        = string
  default     = null
}

variable "gateway_ip" {
  description = "Address to add default route via"
  type        = string
  default     = ""
}

variable "cluster_nodename_template" {
  description = <<-EOT
        Template for node fully-qualified names. The following interpolations
        can be used:
            $${cluster_name}: From var.cluster_name
            $${cluster_domain_suffix}: From var.cluster_domain_suffix
            $${node}: The current entry in the "nodes" parameter for nodes
            defined by var.compute and var.login, or "control" for the control
            node
            $${environment_name}: The last element of the current environment's path
    EOT
  type        = string
  default     = "$${cluster_name}-$${node}.$${cluster_name}.$${cluster_domain_suffix}"
}

variable "config_drive" {
  description = <<-EOT
        Whether to enable Nova config drives on all nodes, which will attach a drive containing
        information usually provided through the metadata service.
    EOT
  type        = bool
  default     = null
}

variable "additional_cloud_config" {
  description = <<-EOT
        Multiline string to be appended to the node's cloud-init cloud-config user-data.
        Must be in yaml format and not include the #cloud-config or any other user-data headers.
        See https://cloudinit.readthedocs.io/en/latest/explanation/format.html#cloud-config-data.
        Can be a templatestring parameterised by `additional_cloud_config_vars`.
        The `boot-cmd`, `fqdn` and `mounts` modules must not be specified.
    EOT
  type        = string
  default     = ""
}

variable "additional_cloud_config_vars" {
  description = "Map of values passed to the `additional_cloud_config` templatestring"
  type        = map(any)
  default     = {}
}
