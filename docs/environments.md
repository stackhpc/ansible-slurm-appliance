# Environments

## Overview

An environment defines the configuration for a single instantiation of this Slurm appliance. Each environment is a directory in `environments/`, containing:
- Any deployment automation required - e.g. OpenTofu configuration or HEAT templates.
- An Ansible `inventory/` directory.
- An `activate` script which sets environment variables to point to this configuration.
- Optionally, additional playbooks in `hooks/` to run before or after to the default playbooks.

All environments load the inventory from the `common` environment first, with the environment-specific inventory then overriding parts of this as required.

### Environment-specific inventory structure

The ansible inventory for the environment is in `environments/<environment>/inventory/`. It should generally contain:
- A `hosts` file. This defines the hosts in the appliance. Generally it should be templated out by the deployment automation so it is also a convenient place to define variables which depend on the deployed hosts such as connection variables, IP addresses, ssh proxy arguments etc.
- A `groups` file defining ansible groups, which essentially controls which features of the appliance are enabled and where they are deployed. This repository generally follows a convention where functionality is defined using ansible roles applied to a group of the same name, e.g. `openhpc` or `grafana`. The meaning and use of each group is described in comments in `environments/common/inventory/groups`. As the groups defined there for the common environment are empty, functionality is disabled by default and must be enabled in a specific environment's `groups` file. Two template examples are provided in `environments/commmon/layouts/` demonstrating a minimal appliance with only the Slurm cluster itself, and an appliance with all functionality.
- Optionally, group variable files in `group_vars/<group_name>/overrides.yml`, where the group names match the functional groups described above. These can be used to override the default configuration for each functionality, which are defined in `environments/common/inventory/group_vars/all/<group_name>.yml` (the use of `all` here is due to ansible's precedence rules).

Although most of the inventory uses the group convention described above there are a few special cases:
- The `control`, `login` and `compute` groups are special as they need to contain actual hosts rather than child groups, and so should generally be defined in the templated-out `hosts` file.
- The cluster name must be set on all hosts using `openhpc_cluster_name`. Using an `[all:vars]` section in the `hosts` file is usually convenient.
- `environments/common/inventory/group_vars/all/defaults.yml` contains some variables which are not associated with a specific role/feature. These are unlikely to need changing, but if necessary that could be done using a `environments/<environment>/inventory/group_vars/all/overrides.yml` file.
- The `ansible/adhoc/generate-passwords.yml` playbook sets secrets for all hosts in `environments/<environent>/inventory/group_vars/all/secrets.yml`.
- The Packer-based pipeline for building compute images creates a VM in groups `builder` and `compute`, allowing build-specific properties to be set in `environments/common/inventory/group_vars/builder/defaults.yml` or the equivalent inventory-specific path.
- Each Slurm partition must have:
    - An inventory group `<cluster_name>_<partition_name>` defining the hosts it contains - these must be homogenous w.r.t CPU and memory.
    - An entry in the `openhpc_slurm_partitions` mapping in `environments/<environment>/inventory/group_vars/openhpc/overrides.yml`.
    See the [openhpc role documentation](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) for more options.
- On an OpenStack cloud, rebuilding/reimaging compute nodes from Slurm can be enabled by defining a `rebuild` group containing the relevant compute hosts (e.g. in the generated `hosts` file).
