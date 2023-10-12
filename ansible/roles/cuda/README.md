# cuda

Install NVIDIA CUDA. The CUDA binaries are added to the PATH for all users, and the [NVIDIA persistence daemon](https://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-daemon) is enabled.

## Prerequisites

Requires OFED to be installed to provide required kernel-* packages.

## Role Variables

- `cuda_distro`: Optional. Default `rhel8`.
- `cuda_repo`: Optional. Default `https://developer.download.nvidia.com/compute/cuda/repos/{{ cuda_distro }}/x86_64/cuda-{{ cuda_distro }}.repo`
- `cuda_driver_stream`: Optional. The default value `default` will, on first use of this role, enable the dkms-flavour `nvidia-driver` DNF module stream with the current highest version number. The `latest-dkms` stream is not enabled, and subsequent runs of the role will *not* change the enabled stream, even if a later version has become available. Changing this value once an `nvidia-driver` stream has been enabled raises an error. If an upgrade of the `nvidia-driver` module is required, the currently-enabled stream and all packages should be manually removed.
- `cuda_packages`: Optional. Default: `['cuda', 'nvidia-gds']`.
- `cuda_persistenced_state`: Optional. State of systemd `nvidia-persistenced` service. Values as [ansible.builtin.systemd:state](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html#parameter-state). Default `started`.
