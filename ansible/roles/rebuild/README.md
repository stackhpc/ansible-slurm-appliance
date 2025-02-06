rebuild
=========

Enables reboot tool from https://github.com/stackhpc/slurm-openstack-tools.git to be run from control node.

Requirements
------------

clouds.yaml file

Role Variables
--------------

- `openhpc_rebuild_clouds`: Directory. Path to clouds.yaml file.


Example Playbook
----------------

    - hosts: control
      become: yes
      tasks:
        - import_role:
            name: rebuild

License
-------

Apache-2.0

