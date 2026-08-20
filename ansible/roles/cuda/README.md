# cuda

Install NVIDIA drivers and optionally CUDA packages. CUDA binaries are added to the `$PATH` for all users, and the [NVIDIA persistence daemon](https://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-daemon) is enabled.

## Role Variables

- `cuda_repo_url`: Optional. URL of `.repo` file. Default is upstream for appropriate OS/architecture.
- `cuda_nvidia_driver_stream`: Optional. Version of `nvidia-driver` stream to enable. This controls whether the open or proprietary drivers are installed and the major version. Changing this once the drivers are installed does not change the version.
- `cuda_packages`: Optional. Default provides CUDA Toolkit and GPUDirect Storage (GDS).
- `cuda_package_version`: Optional. Default `latest` which will install the latest packages if not installed but won't upgrade already-installed packages. Use `'none'` to skip installing CUDA.
- `cuda_persistenced_state`: Optional. State of systemd `nvidia-persistenced` service. Values as [ansible.builtin.systemd:state](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html#parameter-state). Default `started`.

## Running tests

Tests can be run by `ansible-playbook ansible/adhoc/cudatests.yml`.
By default all tests are run.

### nvbandwidth

Downloads, builds and runs <https://github.com/NVIDIA/nvbandwidth>.
Select it with `--tags cuda_bandwidth`.

Variables:

- `cuda_bandwidth_version`: Optional. Version of nvbandwidth to download. Default `0.8`
- `cuda_bandwidth_path`: Optional. Path to download nvbandwidth to. Default `/var/lib/{{ ansible_user }}/cuda_bandwidth`

### cuda_samples

Downloads, builds and runs <https://github.com/NVIDIA/cuda-samples>.
Select it with `--tags cuda_samples`.

Compilation with `cuda_samples_build_concurrency > 1` crashes on some problematic systems
but should be fine in general.

Variables:

- `cuda_samples_build_concurrency`: Optional. `make -j` flag for build concurrency. Defaults to `ansible_processor_vcpus`.
- `cuda_samples_run_tests_concurrency`: Optional. How many applications from cuda_samples to run in parallel. Defaults to `1`.
