# autoscale

Support autoscaling nodes on OpenStack clouds, i.e. creating nodes when necessary to service the queue and deleting them when they are no longer needed.

This is implemented using Slurm's ["elastic computing"](https://slurm.schedmd.com/elastic_computing.html) features which are based on Slurm's [power saving](https://slurm.schedmd.com/power_save.html) features.

Add the `control` group to the `autoscale` group to activate this functionality in the `ansible/slurm.yml` playbook. Note some role variables are likely to need configuring. By default, node creation and deletion will be logged in the control node's syslog.

## Requirements

- Working DNS.
- Active OpenStack credentials on localhost (e.g a sourced `openrc.sh` in the shell running ansible).
- Role `stackhpc.slurm_openstack_tools.pytools`. Installs [slurm-openstack-tools](github.com/stackhpc/slurm-openstack-tools) which provides a venv with the `openstacksdk` and the required resume/suspend scripts.
- Role `stackhpc.openhpc` to create a Slurm cluster.
- This role should be run on the Slurm controller only.

## Role Variables

- `autoscale_clouds`: Optional, path to a `clouds.yaml` file containing a single cloud. Defaults to `~/.config/openstack/clouds.yaml`. It is recommended this is an [application credential](https://docs.openstack.org/keystone/latest/user/application_credentials.html). This can be created in Horizon via Identity > Application Credentials > +Create Application Credential. The usual role required is `member`. Using access rules has been found not to work at present. Note that the downloaded credential can be encrpyted using `ansible-vault` to allow it to be committed to source control. It will automatically be decrypted when copied onto the compute nodes.

The following variables are likely to need tuning for the specific site/instances:
- `autoscale_suspend_time`: Optional, default 120s. See `slurm.conf` parameter [SuspendTime](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_SuspendTime).
- `autoscale_suspend_timeout`: Optional, default 30s. See `slurm.conf` parameter [SuspendTimeout](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_SuspendTimeout).
- `autoscale_resume_timeout`: Optional, default 300s See `slurm.conf` parameter [ResumeTimeout](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_ResumeTimeout).

The following variables may need altering for production:
- `autoscale_show_suspended_nodes`: Optional, default `true`. Whether to show suspended/powered-down nodes in `sinfo` etc. See `slurm.conf` parameter [PrivateData - cloud](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_cloud).
- `autoscale_debug_powersaving`: Optional, default `true`. Log additional information for powersaving, see `slurm.conf` parameter [DebugFlags - PowerSave](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_PowerSave_2).
- `autoscale_slurmctld_syslog_debug`: Optional, default `info`. Syslog logging level. See `slurm.conf` parameter [SlurmctldSyslogDebug](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_SlurmctldSyslogDebug).
- `autoscale_suspend_exc_nodes`: Optional. List of nodenames (or Slurm hostlist expressions) to exclude from "power saving", i.e. they will not be autoscaled away.

## stackhpc.openhpc role variables
This role modifies what the [openhpc_slurm_partitions variable](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) in the `stackhpc.openhpc` role accepts. Partition/group definitions may additionally include:
- `cloud_nodes`: Optional. Slurm hostlist expression (e.g. `'small-[8,10-16]'`) defining names of nodes to be defined in a ["CLOUD" state](https://slurm.schedmd.com/slurm.conf.html#OPT_CLOUD), i.e. not operational when the Slurm control daemon starts.
- `cloud_instances`: Required if `cloud_nodes` is defined. A mapping with keys `flavor`, `image`, `keypair` and `network` defining the OpenStack ID or names of properties for the CLOUD-state instances.

Partitions/groups defining `cloud_nodes` may or may not also contain non-CLOUD state nodes (i.e. nodes in a matching inventory group). For CLOUD-state nodes, memory and CPU information is retrieved from OpenStack for the specified flavors. The `stackhpc.openhpc` group/partition options `ram_mb` and `ram_multiplier` and role variable `openhpc_ram_multiplier` are handled exactly as for non-CLOUD state nodes. This implies that if CLOUD and non-CLOUD state nodes are mixed in a single group all nodes must be homogenous in terms of processors/memory.

Some examples are given below. Note that currently monitoring is not enabled for CLOUD-state nodes.

### Examples

Below is an example of partition definition, e.g. in `environments/<environment>/inventory/group_vars/openhpc/overrides.yml`. Not shown here the inventory group `dev_small` contains 2 (non-CLOUD state) nodes. The "small" partition is the default and contains 2 non-CLOUD and 2 CLOUD nodes. The "burst" partition contains only CLOUD-state nodes.

```yaml
openhpc_cluster_name: dev
general_v1_small:
  image: ohpc-compute-210909-1316.qcow2
  flavor: general.v1.small
  keypair: centos-at-steveb-ansible
  network: stackhpc-ipv4-geneve

general_v1_medium:
  image: ohpc-compute-210909-1316.qcow2
  flavor: general.v1.medium
  keypair: centos-at-steveb-ansible
  network: stackhpc-ipv4-geneve

openhpc_slurm_partitions:
- name: small
  default: yes
  cloud_nodes: dev-small-[2-3]
  cloud_instances: "{{ general_v1_small }}"

- name: burst
  default: no
  cloud_nodes: 'burst-[0-3]'
  cloud_instances: "{{ general_v1_medium }}"
```

# Dependencies

`stackhpc.openhpc` role as described above.

# Example Playbook

See ansible/slurm.yml

# License

Apache v2

# Author Information

StackHPC Ltd.
