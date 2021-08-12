Role Name
=========

An MPI-based test suite for Slurm appliance clusters.

Unlike `https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/tree/main/roles/test/` this is designed to be safe to use on clusters in production. Instead of exporting installs from `/opt/*` over NFS the required packages are installed by default - see `environments/common/inventory/group_vars/all/openhpc.yml`.

Requirements
------------

An OpenHPC v2.x cluster.

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

See `defaults/main.yml`.

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
