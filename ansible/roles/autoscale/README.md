# autoscale

Support autoscaling nodes on OpenStack clouds, i.e. creating nodes when necessary to service the queue and deleting them when they are no longer needed.

This is implemented using Slurm's ["elastic computing"](https://slurm.schedmd.com/elastic_computing.html) features which are based on Slurm's [power saving](https://slurm.schedmd.com/power_save.html) features.


NOTES TODO:
- Won't get monitoring for autoscaling nodes
- Describe autoscale vs `State=CLOUD` and powersaving enablement.
- Describe groups.
- Describe cpu/memory info requirements (inc. for mixed partitions)
- Describe what happens on failure.
- Note that DNS is REQUIRED for this.

## Requirements

- Role `stackhpc.slurm_openstack_tools.pytools`. Installs [slurm-openstack-tools](github.com/stackhpc/slurm-openstack-tools) which provides a venv with the `openstacksdk`.
- Role `stackhpc.openhpc` to create a Slurm cluster.
- This role should be run on the Slurm controller only, i.e. add the `control` group to the `autoscale` group to activate this functionality.

## Role Variables

- `openhpc_slurm_partitions`: This role modifies what the partitions/groups defined [openhpc_slurm_partitions](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) in the by `stackhpc.openhpc` role accept:
  - `cloud_nodes`: Optional. As per the `stackhpc.openhpc` docs this defines nodes in a ["CLOUD" state](https://slurm.schedmd.com/slurm.conf.html#OPT_CLOUD), i.e. treated as powered down/not existing when the Slurm control daemon starts. The value is a suffix for the group/partition's node names in Slurm's hostlist expression format (e.g. `-[11-25]`) and therefore defines the number of CLOUD-state nodes.
  - `cloud_instances`: Required if `cloud_nodes` is defined. A dict defining the `flavor`, `image`, `keypair` and `network` to use for CLOUD-state instances in this partition/group. Values for these parameters may be either names (if unique in the cloud) or IDs.
  
  Some examples are given below.

- `autoscale_show_suspended_nodes`: Optional, default `true`. Whether to show suspended/powered-down nodes in `sinfo` etc. See `slurm.conf` parameter [PrivateData - cloud](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_cloud).

The following variables have defaults useful for debugging autoscaling, but may be altered for production:
- `autoscale_debug_powersaving`: Optional, default `true`. Log additional information for powersaving, see `slurm.conf` parameter [DebugFlags - PowerSave](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_PowerSave_2).
- `autoscale_slurmctld_syslog_debug`: Optional, default `info`. Syslog logging level. See `slurm.conf` parameter [SlurmctldSyslogDebug](https://slurm.schedmd.com/archive/slurm-20.11.7/slurm.conf.html#OPT_SlurmctldSyslogDebug).

The following variables are likely to need tuning for the specific site/instances:
- `autoscale_suspend_time`: Optional, default 120s TODO https://slurm.schedmd.com/slurm.conf.html#OPT_SuspendTime
- `autoscale_suspend_timeout`: Optional, default 30s TODO https://slurm.schedmd.com/slurm.conf.html#OPT_SuspendTimeout
- `autoscale_resume_timeout`: Optional, default 300s TODO https://slurm.schedmd.com/slurm.conf.html#OPT_ResumeTimeout

### Processor/memory information
Non-CLOUD-state nodes in a group/partition are defined by the hosts in an inventory group named `<cluster_name>_<group_name>` as per `stackhpc.openhpc` [docs](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) and processor/memory information is automatically retrieved from them.

- If a group/partition contains both CLOUD and non-CLOUD nodes the processor/memory information for the CLOUD nodes is assumed to match that retrieved for the non-CLOUD nodes.
- If a group/partition only contains CLOUD-state nodes (i.e. no matching inventory group or it is empty) then processor/memory information must be specified using the `ram_mb`, `sockets`, `cores_per_socket` and `threads_per_core` options.




  
  ```yaml
  cloud_instances:
    flavor: general.v1.medium
    image: ohpc-compute-210909-1316.qcow2
    keypair: centos-at-steveb-ansible
    network: "{{ autoscale_network }}"

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.




Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
