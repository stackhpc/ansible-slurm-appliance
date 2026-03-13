# topology

Templates out /etc/slurm/topology.conf file based on an OpenStack project for use by
Slurm's [topology/tree plugin.](https://slurm.schedmd.com/topology.html) Models
cluster as tree with a hierarchy of:

Top-level inter-rack Switch -> Availability Zones -> Hypervisors -> VMs

Warning: This role doesn't currently trigger a restart of Slurm so will therefore not
reconfigure an already running cluster after a `ansible/site.yml` run. You will therefore need
to run the `ansible/adhoc/restart-slurm.yml` playbook for changes to topology.conf to be
recognised.

## Role Variables

- `topology_nodes:`: Required list of strs. List of inventory hostnames of nodes to include in topology tree. Must be set to include all compute nodes in Slurm cluster. Default `[]`.
- `topology_conf_template`: Optional str. Path to Jinja2 template of topology.conf file. Default
  `templates/topology.conf.j2`
- `topology_above_rack_topology`: Optionally multiline str. Used to define topology above racks/AZs if
  you wish to partition racks further under different logical switches. New switches above should be
  defined as [SwitchName lines](https://slurm.schedmd.com/topology.html#hierarchical) referencing
  rack Availability Zones under that switch in their `Switches fields`. These switches must themselves
  be under a top level switch. e.g

  ```yaml
  topology_above_rack_topology: |
    SwitchName=rack-group-1 Switches=rack-az-1,rack-az-2
    SwitchName=rack-group-2 Switches=rack-az-3,rack-az-4
    SwitchName=top-level Switches=rack-group-1,rack-group-2
  ```

  Defaults to an empty string, which causes all AZs to be put under a
  single top level switch.
