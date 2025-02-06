slurm_tools
=========

Install python-based tools from https://github.com/stackhpc/slurm-openstack-tools.git into `/opt/slurm-tools/bin/`.

Role Variables
--------------

- `pytools_editable`: Optional bool. Whether to install the package using `pip`'s
  editable mode (installing source to `/opt/slurm-tools/src`). Default `false`.
- `pytools_gitref`: Optional. Git branch/tag/commit etc to install. Default `master`.
- `pytools_user`: Optional user to install as. Default `root`.
