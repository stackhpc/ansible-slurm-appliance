# cuda

Install NVIDIA drivers and optionally CUDA packages. CUDA binaries are added to the `$PATH` for all users, and the [NVIDIA persistence daemon](https://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-daemon) is enabled.

## Prerequisites

Requires OFED to be installed to provide required kernel-* packages.

## Role Variables

- `cuda_repo_url`: Optional. URL of `.repo` file. Default is upstream for appropriate OS/architecture.
- `cuda_nvidia_driver_stream`: Optional. Version of `nvidia-driver` stream to enable. This controls whether the open or proprietary drivers are installed and the major version. Changing this once the drivers are installed does not change the version.
- `cuda_packages`: Optional. Default: `['cuda', 'nvidia-gds']`.
- `cuda_package_version`: Optional. Default `latest` which will install the latest packages if not installed but won't upgrade already-installed packages. Use `'none'` to skip installing CUDA.
- `cuda_persistenced_state`: Optional. State of systemd `nvidia-persistenced` service. Values as [ansible.builtin.systemd:state](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html#parameter-state). Default `started`.
