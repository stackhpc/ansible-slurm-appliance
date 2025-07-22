topology
========

Templates out /etc/slurm/topology.conf file based on an Openstack project for use by
Slurm's [topology/tree plugin.](https://slurm.schedmd.com/topology.html) Models
cluster as tree with a heirarchy of:

Top-level inter-rack Switch -> Availability Zones -> Hypervisors -> VMs

Role Variables
--------------

- `topology_topology_nodes:`: Required list of strs. List of inventory hostnames of nodes to include in topology tree. Must be set to include all compute nodes in Slurm cluster. Default `[]`.
- `topology_conf_template`: Optional str. Path to Jinja2 template of topology.conf file. Default
  `templates/topology.conf.j2`