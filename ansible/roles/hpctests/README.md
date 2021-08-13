Role Name
=========

An MPI-based test suite for Slurm appliance clusters.

This is intended as a replacement for [this test role](`https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/tree/main/roles/test/`) but will be safe to run on clusters in production use as it does not use NFS exports for package installs. Instead it assumes the required packages are pre-installed, which is the case by default with this appliance. 

Currently only the `pingpong` and `pingmatrix` tests from the above are implemented.

Available tags:
  - pingpong
  - pingmatrix

Requirements
------------

- An OpenHPC v2.x cluster.
- Packages installed listed at `environments/common/inventory/group_vars/all/openhpc.yml`.

Role Variables
--------------

- `hpctests_rootdir`: Required. Path to root of test directory tree, which must be on a r/w filesystem shared to all cluster nodes under test. The last directory component will be created.
- `hpctests_pingmatrix_modules`: Optional. List of modules to load for pingmatrix test. Defaults are suitable for OpenHPC 2.x cluster using the required packages.
- `hpctests_pingpong_modules`: As above but for pingpong test.
- `hpctests_outdir`: Directory to use for test output on local host. Defaults to `$HOME/hpctests` (for local user).

Dependencies
------------

None.

Example Playbook
----------------

The role should be run on a login node;

```yaml
- hosts: login[0]
  become: false
  gather_facts: false
  vars:
    hpctests_rootdir: "/home/hpctests"
  tasks:
    - import_role:
        name: hpctests
```

License
-------

Apache v2

Author Information
------------------

stackhpc.com
