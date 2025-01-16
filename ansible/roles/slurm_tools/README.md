stackhpc.slurm_openstack_tools.pytools
=========

Installs python-based tools from https://github.com/stackhpc/slurm-openstack-tools.git into `/opt/slurm-tools/bin/`.

Requirements
------------

Role Variables
--------------

`pytools_editable`: Optional. Whether to install the package using `pip`'s editable mode (installing source to `/opt/slurm-tools/src`) - `true` or `false` (default).
`pytools_gitref`: Optional. Git branch, version, commit etc to install. Default `master`.
`pytools_user`: User to install as. Default `root`.

Dependencies
------------
None.

Example Playbook
----------------

    - hosts: compute
      tasks:
        - import_role:
            name: stackhpc.slurm_openstack_tools.pytools
        

License
-------

Apache-2.0

Author Information
------------------

