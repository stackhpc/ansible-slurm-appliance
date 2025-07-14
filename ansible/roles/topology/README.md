topology
========

Templates out /etc/slurm/topology.conf file based on an Openstack project for use by
Slurm's [topology/tree plugin.](https://slurm.schedmd.com/topology.html) Models
project as tree with a heirarchy of:

Project -> Availability Zones -> Hypervisors -> VMs

Role Variables
--------------

- `topology_topology_nodes: []`: Required list[str]. List of nodes to include in topology tree. Must be set to include all compute nodes in Slurm cluster. Default `[]`.
- `topology_topology_override:`: Optional str. If set, will override templating and be provided as custom topology.conf content. Undefined by default.