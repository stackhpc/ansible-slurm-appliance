# terraform

Define infrastructure using Terraform from Ansible inventory:
- Creates Terraform configuration files from Jinja templates using Ansible inventory variables.
- Runs `terraform apply` on the configuration.

Note by default interactive user confirmation is required before making changes to infrastructure.

# Role Variables

These are split into three:
- `cluster_*` variables define infrastructure parameters which are the same across all nodes. They must be defined as `all` groupvars.
- `node_*` variables define instructure parameters which *may* vary between nodes. They may be defined in `all` groupvars, specific groupvars or hostvars.
- `tf_*` variables control operation of the role itself.

## `cluster_*` and `node_*` variables

### Required variables
These have no default values and must be specified for an environment (e.g. in `environments/<environment>/inventory/cluster.yml`):
- `cluster_key_pair`: Name of an existing OpenStack keypair.
or
- `cluster_ssh_keys`: List of public SSH keys to add as authorized keys.
Note the private key for one of these public keys must be on the deploy host to allow configuration of the cluster.

- `cluster_network_name`: Required unless `node_interfaces` is defined. Name of existing network to use for cluster.
- `node_flavor_name` or `node_flavor_id`: Name or ID of flavor.
- `node_image_name` or `node_image_id`: Name or ID of image.

### Optional variables
Defaults for these are provided by [environments/common/inventory/cluster.yml](../../../environments/common/inventory/cluster.yml):

- `cluster_name`: Name of cluster. Defaults to the name of the current environment directory.
- `cluster_tld`: Top level domain name for nodes. Default `invalid` which is [guaranteed](https://www.rfc-editor.org/rfc/rfc2606.html#section-2) not to exist in global DNS.

- `cluster_security_groups`: List of security group mappings as follows:
    - `name`: Required. Unique name for this security group.
    - `description`: Required. Description.
    - `rules`: Required. List of security group rule mappings (see [openstack_networking_secgroup_v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) for details) as follows:
        - `direction`: Required, `ingress` or `egress`.
        - `ethertype`: Optional, default `IPv4`.
        - `remote_group`: Optional, name of a security group in `cluster_security_groups`.
        - `protocol`: Required if `port` specified.
        - `port`: Allowed port number.
    
    Note security groups are cluster-specific (they will be prefixed with `cluster_name`) and any default OpenStack rules will not be applied. The defaults allow:
    - All IPv4 traffic between all cluster nodes.
    - All outbound IPv4 traffic from all cluster nodes.
    - Inbound SSH and HTTPS on `login` nodes.

- `node_interfaces`: List of mappings defining the network interfaces for a node (see [openstack_networking_port_v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2) for details) as follows:
    - `network_name`: Required. Name of existing network.
    - `fixed_ip`: Optional. Mapping defining the fixed/private IP as follows:
        - `subname_name`: Optional, name of subnet to use.
        - `ip_address`: Optional, address to use for port.
    - `port_security_enabled`: Optional bool, whether to explictly enable or disable port security or use the OpenStack defaults (usually `true`). If `false` no security groups must be defined on this interface.
    - `security_groups`: Optional, list of names of security groups defined in `cluster_security_groups`. NB: Currently externally-defined security groups cannot be applied.
    - `binding`: Optional. Mapping defining port binding information:
        - `vnic_type`: Optional. Type of VNIC, as per [openstack_networking_port_v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_port_v2). Useful for RDMA-capable interfaces or baremetal nodes.
        - `profile`: Optional. Custom binding profile mapping (converted to JSON internally). Useful for some RDMA-capable interfaces.

- `node_fqdn`: Fully-qualified domain name of the node. Default `{{ inventory_hostname }}.{{ cluster_name }}.{{ cluster_tld }}`.
- `node_volumes`: List of mappings defining empty OpenStack volumes to create and attach to the node as follows:
    - `label`: Required. Label for volume, used to mount it.
    - `description`: Optional.
    - `size`: Size in GB of volume.
    - `filesystem`: Optional. Type of filesystem, default `ext4`.
    - `mount_point`: Required. Path of mount point (will be created if necessary).
    - `mount_options`: Optional. Comma-separated string giving mount options as per the fourth (fs_mntops) field in `/etc/fstab`.
    The default is to attach two volumes to the `control` node, for user `$HOME` and state information. The sizes of these are defined by `home_volume_size` and `state_volume_size`.
    See also `node_volume_device_prefix`.
- `node_volume_device_prefix`: Prefix of path at which volumes will be mounted, default `/dev/vd`. Note if `virtio-scsi` properties are set on the image this should be changed to `/dev/sd`.
- `node_tf_ignore_changes`: List of strings giving Terraform [openstack_compute_instance_v2](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2) attributes to ignore when calculating changes to instances. See `ignore_changes` for Terraform's [lifecycle meta-argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle).
- `node_user_data`: String of cloud-init userdata. Default is empty for all nodes except `control`, where it defines the filesystems and mounts for `node_volumes`.
- `node_floating_ip_address`: Address of floating IP to attach to a node. NB specifying a particular network is not currently supported.

## `tf_*` variables
Default values for these are provided in the role:
- `tf_project_path`: Optional. Where to output Terraform configuration files. Default `{{ appliances_environment_root }}/terraform/`.
- `tf_cluster_templates`: Optional. List of Jinja templates to template once per cluster, using `localhost`. Default is the in-role files `main.tf.j2`, `network.tf.j2`, `inventory.tf.j2`.
- `tf_host_templates`: Optional. List of Jinja templates to template per-host. Default is the in-role file `node.tf.j2`.
- `tf_autoapprove`: Optional bool. Set true to make infrastructure changes without user confirmation. Default `no`.
