# cuda

Install NVIDIA CUDA. The CUDA binaries are added to the PATH for all users, and the [NVIDIA persistence daemon](https://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-daemon) is enabled.

## Prerequisites

Requires OFED to be installed to provide required kernel-* packages.

## Role Variables

- `cuda_distro`: Optional. Default `rhel8`.
- `cuda_repo`: Optional. Default `https://developer.download.nvidia.com/compute/cuda/repos/{{ cuda_distro }}/x86_64/cuda-{{ cuda_distro }}.repo`
- `cuda_packages`: Optional. Default: `['cuda', 'nvidia-gds']`.
