stackhpc.slurm_openstack_tools.slurm-stats
==========================================

Configures slurm-stats from https://github.com/stackhpc/slurm-openstack-tools.git which
transforms sacct output into a form that is more amenable for importing into elasticsearch/loki.

Requirements
------------

Role Variables
--------------

See `defaults/main.yml`.

Dependencies
------------

Example Playbook
----------------

    - hosts: compute
      tasks:
        - import_role:
            name: stackhpc.slurm_openstack_tools.slurm-stats


License
-------

Apache-2.0

Author Information
------------------
