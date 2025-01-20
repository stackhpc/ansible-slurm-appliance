# doca

Install [NVIDIA DOCA](https://docs.nvidia.com/doca/sdk/index.html).

This role is not idempotent and is only intended to be run during an image build. It builds DOCA kernel modules to match the installed kernel and then installs these
plus the selected DOCA packages.

## Role Variables

- `doca_version`: Optional. String giving doca version.
- `doca_profile`: Optional. Name of [profile](https://docs.nvidia.com/doca/sdk/nvidia+doca+profiles/index.html) defining subset of DOCA to install. Default is `doca-ofed`.
- `doca_repo_url`: Optional. URL of DOCA repository. Default is appropriate upstream public repository for DOCA version, distro version and architecture.
