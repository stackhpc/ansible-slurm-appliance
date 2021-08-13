Role Name
=========

An MPI-based test suite for Slurm appliance clusters.

This is intended as a replacement for [this test role](`https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/tree/main/roles/test/`) but will be safe to run on clusters in production use as it does not use NFS exports for package installs. Instead it assumes the required packages are pre-installed, which is the case by default with this appliance. 

Tests (with corresponding tags) are:
- `pingpong`: Runs Intel MPI Benchmark's IMB-MPI1 pingpong between a pair of (scheduler-selected) nodes. Reports zero-size message latency and maximum bandwidth.
- `pingmatrix`: Runs a similar pingpong test but between all pairs of nodes. Reports zero-size message latency & maximum bandwidth.

Note the HPL-based tests from the above role are currently not supported.

By default these tests use OpenMPI v4 with UCX. Currently UCX's [default network device selection](https://openucx.readthedocs.io/en/master/faq.html#what-is-the-default-behavior-in-a-multi-rail-environment) cannot be modified via this role which may be inappropriate for multi-rail nodes with widely-differing bandwidths.

Requirements
------------

- An OpenHPC v2.x cluster.
- Packages installed listed at `environments/common/inventory/group_vars/all/openhpc.yml`.

Role Variables
--------------

- `hpctests_rootdir`: Required. Path to root of test directory tree, which must be on a r/w filesystem shared to all cluster nodes under test. The last directory component will be created.
- `hpctests_ucx_net_devices`: Optional. Control which network device/interface to use, e.g. `mlx5_1:0`. The default of `all` (as per UCX) may not be appropriate for multi-rail nodes with different bandwidths on each device. See [here](https://openucx.readthedocs.io/en/master/faq.html#what-is-the-default-behavior-in-a-multi-rail-environment) and [here](https://github.com/openucx/ucx/wiki/UCX-environment-parameters#setting-the-devices-to-use).
- `hpctests_outdir`: Optional. Directory to use for test output on local host. Defaults to `$HOME/hpctests` (for local user).
- `hpctests_pingmatrix_modules`: Optional. List of modules to load for pingmatrix test. Defaults are suitable for OpenHPC 2.x cluster using the required packages.
- `hpctests_pingpong_modules`: As above but for pingpong test.

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
