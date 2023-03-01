# cuda

Install NVIDIA CUDA.

## Prerequisites

Requires OFED to be installed to provide required kernel-* packages.

## Role Variables

- `cuda_distro`: Optional. Default `rhel8`.
- `cuda_repo`: Optional. Default `https://developer.download.nvidia.com/compute/cuda/repos/{{ cuda_distro }}/x86_64/cuda-{{ cuda_distro }}.repo`
- `cuda_packages`: Optional. Default: `['cuda', 'nvidia-gds']`.
