# hpctests

An MPI-based test suite for Slurm appliance clusters.

This is intended as a replacement for [this test role](https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/tree/main/roles/test/) but will be safe to run on clusters in production use as it does not use NFS exports for package installs. Instead it assumes the required packages are pre-installed, which is the case by default with this appliance.

Tests (with corresponding tags) are:

- `pingpong`: Runs Intel MPI Benchmark's IMB-MPI1 pingpong between a pair of (scheduler-selected) nodes. Reports zero-size message latency and maximum bandwidth.
- `pingmatrix`: Runs a similar pingpong test but between all pairs of nodes. Reports zero-size message latency & maximum bandwidth.
- `hpl-solo`: Runs the HPL benchmark individually on all nodes. Reports Gflops.
- `gpuburn`: Runs the [gpuburn](https://github.com/wilicc/gpu-burn/) utility to load-test GPUs. Reports Gflops.

All tests use GCC 9 and OpenMPI 4 with UCX. The HPL-based tests use OpenBLAS.

## Requirements

- An OpenHPC v2.x cluster.
- The following OpenHPC packages installed (note this is the default in the appliance, see `environments/common/inventory/group_vars/all/openhpc.yml:openhpc_default_packages`):
  - `ohpc-gnu9-openmpi4-perf-tools`
  - `openblas-gnu9-ohpc`

## Role Variables

- `hpctests_user`: Optional. User to run jobs as. Default is `ansible_user`.
- `hpctests_group`: Optional. Group to own created files. Default is `hpctests_user`.
- `hpctests_rootdir`: Optional. Path to root of test directory tree. This must
  be a r/w filesystem shared to all cluster nodes under test. Default is
  `/home/{{ hpctests_user }}/hpctests`. **NB:** Do not use `~` in this path.
- `hpctests_account`: Optional. Slurm account to use, otherwise no account is specified to Slurm.
- `hpctests_partition`: Optional. Name of partition to use, otherwise default partition is used.
- `hpctests_qos`: Optional. Slurm QoS to use, otherwise no qos is specified to Slurm.
- `hpctests_nodes`: Optional. A Slurm node expression, e.g. `'compute-[0-15,19]'` defining the nodes to use. If not set all nodes in the selected partition are used.
- `hpctests_ucx_net_devices`: Optional. Control which network device/interface to use, e.g. `mlx5_1:0`.
  The default of `all` (as per UCX) may not be appropriate for multi-rail nodes with different bandwidths on each device. See [here](https://openucx.readthedocs.io/en/master/faq.html#what-is-the-default-behavior-in-a-multi-rail-environment) and [here](https://github.com/openucx/ucx/wiki/UCX-environment-parameters#setting-the-devices-to-use).
  Alternatively a mapping of partition name (as `hpctests_partition`) to device/interface can be used. For partitions not defined in the mapping the default of `all` is used.
- `hpctests_outdir`: Optional. Directory to use for test output on local host. Defaults to `$APPLIANCES_ENVIRONMENT_ROOT/hpctests`.
- `hpctests_hpl_NB`: Optional, default 192. The HPL block size "NB" - for Intel CPUs see [here](https://software.intel.com/content/www/us/en/develop/documentation/onemkl-linux-developer-guide/top/intel-oneapi-math-kernel-library-benchmarks/intel-distribution-for-linpack-benchmark/configuring-parameters.html).
- `hpctests_hpl_mem_frac`: Optional, default 0.3. The HPL problem size "N" will
  be selected to target using this fraction of each node's memory -
  **CAUTION: see note below**.
- `hpctests_hpl_arch`: Optional, default 'linux64'. Arbitrary architecture name for HPL build. HPL is compiled on the first compute node of those selected (see `hpctests_nodes`), so this can be used to create different builds for different types of compute node.
- `hpctests_cuda_compute_level`: Optional, default '8.0' which is good for A100 and newer. Cuda compute level used for gpuburn's compare kernel. Check <https://developer.nvidia.com/cuda/GPUs> for compatibility with target hardware.
- `hpctests_gpuburn_gres`: Optional, all GPUs will be selected if absent. `srun --gres` option: needed on hosts with heterogeneous cards (incl. MIG). eg. `gpu:nvidia_h200=2gpu`
- `hpctests_gpuburn_minutes`: Optional, default 20. Duration in minutes of gpuburn's GPU load.
- `hpctests_gpuburn_node_chunk_percent`: Optional, default 10. Portion of all nodes to run gpuburn on at a time (by default, only run on 10% of the nodes at the time, rounded upward).
- `hpctests_gpuburn_node_chunk_size`: Optional, default computed from hpctests_gpuburn_node_chunk_percent and hpctests_nodes and partition size. How many nodes to run gpuburn on at a time

---

**CAUTION**

> The default of `hpctests_hpl_mem_frac=0.3` will not significantly load nodes.
> Values up to ~0.8 may be appropriate for a stress test but ensure cloud
> operators are aware in case this overloads e.g. power supplies or cooling.
> Values > 0.8 require longer runtimes and increase the risk of out-of-memory

## errors without normally significantly increasing the stress on the node

The following variables should not generally be changed:

- `hpctests_pre_cmd`: Optional. Command(s) to include in sbatch templates before module load commands.
- `hpctests_pingmatrix_modules`: Optional. List of modules to load for pingmatrix test. Defaults are suitable for OpenHPC 2.x cluster using the required packages.
- `hpctests_pingpong_modules`: As above but for pingpong test.
- `hpctests_pingpong_plot`: Whether to plot pingpong results. Default `yes`.
- `hpctests_hpl_modules`: As above but for hpl tests.
- `hpctests_hpl_version`: Version of HPL

## Dependencies

None.

## Example Playbook

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

## License

Apache v2

## Author Information

stackhpc.com
