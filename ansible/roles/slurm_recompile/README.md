# slurm_recompile
=================

Recompiles slurm from source RPMs and installs the packages that were built.

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
            name: slurm_stats


License
-------

Apache-2.0

