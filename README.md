# StackHPC Slurm Appliance

This repository contains playbooks and configuration to define a Slurm-based HPC environment including:
- A Centos 8 and OpenHPC v2-based Slurm cluster.
- Shared fileystem(s) using NFS (with servers within or external to the cluster).
- Slurm accounting using a MySQL backend.
- A monitoring backend using Prometheus and ElasticSearch.
- Grafana with dashboards for both individual nodes and Slurm jobs.
- Production-ready Slurm defaults for access and memory.
- A Packer-based build pipeline for compute node images.

The repository is designed to be forked for a specific use-case/HPC site but can contain multiple environments (e.g. development, staging and production). It has been designed to be modular and extensible, so if you add features for your HPC site please feel free to submit PRs back upstream to us!

## Pre-requisites

- Working DNS so that we can use the ansible inventory name as the address for connecting to services.
- Bootable images based on Centos 8 Cloud images.

## Installation on deployment host

These instructions assume the deployment host is running Centos 8:

    git clone  git@github.com:stackhpc/openhpc-demo.git
    cd openhpc-demo
    python3 -m venv venv
    . venv/bin/activate
    pip install -U pip
    pip install -r requirements.txt
    # Install ansible dependencies ...
    ansible-galaxy role install -r requirements.yml -p ansible/roles
    ansible-galaxy collection install -r requirements.yml -p ansible/collections # ignore the path warning here


## Overview of directory structure

- `environments/`: Contains configurations for both a "common" environment and one or more environments derived from this for your site. These define ansible inventory and may also contain provisioning automation such as Terraform or OpenStack HEAT templates.
- `ansible/`: Contains the ansible playbooks to configure the infrastruture.
- `packer/`: Contains automation to use Packer to build compute nodes for an enviromment - see the README in this directory for further information.

## Creating a Slurm appliance

NB: This section describes generic instructions - check for any environment-specific instructions in `environments/<environment>/README.md` before starting.

1. Activate the environment - this **must be done** before any other commands are run:

        source environments/<environment>activate

2. Deploy instances - see environment-specific instructions.

3. Generate passwords:

        ansible-playbook ansible/adhoc/generate-passwords.yml

    This will output a set of passwords in `environments/<environment>/inventory/group_vars/all/secrets.yml`. It is recommended that these are encrpyted and then commited to git using:

        ansible-vault encrypt inventory/group_vars/all/secrets.yml
   
    See the [Ansible vault documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for more details.


4. Deploy the appliance:

        ansible-playbook ansible/site.yml

   or if you have encrypted secrets use:

        ansible-playbook ansible/site.yml --ask-vault-password

    Tags as defined in the various sub-playbooks defined in `ansible/` may be used to only run part of the `site` tasks.

5. "Utility" playbooks for managing a running appliance are contained in `ansible/adhoc` - run these by activating the environment and using:

        ansible-playbook ansible/adhoc/<playbook name>

   Currently they include:
    - `test.yml`: MPI-based post-deployment tests for latency, bandwidth and floating point performance. See `ansible/collections/ansible_collections/stackhpc/slurm_openstack_tools/roles/test/README.md` for full details. Note that you may wish to reconfigure the Slurm compute nodes into a single partition before running this.
    **IMPORTANT: Do not use these tests on a cluster in production as the reconfiguration it performs will crash running jobs.**
    - `update-packages.yml`: Update all packages on the cluster.

## Environments

### Overview

An environment defines the configuration for a single instantiation of this Slurm appliance. Each environment is a directory in `environments/', containing:
- Any deployment automation required - e.g. Terraform configuration or HEAT templates.
- An ansible `inventory/` directory.
- An `activate` script which sets environment variables to point to this configuration.
- Optionally, additional playbooks in `/hooks` to run before or after the main tasks.

All environments load the inventory from the `common` environment first, with the environment-specific inventory then overriding parts of this as required.

### Creating a new environment

This repo contains a `cookiecutter` template which can be used to create a new environment from scratch. Run the [installation on deployment host](#Installation-on-deployment-host) instructions above, then in the repo root run:

    . venv/bin/activate
    cookiecutter environments/skeleton

and follow the prompts to complete the environment name and description.

Alternatively, you could copy an existing environment directory.

Now add deployment automation if required, and then complete the environment-specific inventory as described below.

### Environment-specific inventory structure

The ansible inventory for the environment is in `environments/<environment>/inventory/`. It should generally contain:
- A `hosts` file. This defines the hosts in the appliance. Generally it should be templated out by the deployment automation so it is also a convenient place to define variables which depend on the deployed hosts such as connection variables, IP addresses, ssh proxy arguments etc.
- A `groups` file defining ansible groups, which essentially controls which features of the appliance are enabled and where they are deployed. This repository generally follows a convention where functionality is defined using ansible roles applied to a a group of the same name, e.g. `openhpc` or `grafana`. The meaning and use of each group is described in comments in `environments/common/inventory/groups`. As the groups defined there for the common environment are empty, functionality is disabled by default and must be enabled in a specific environment's `groups` file. Two template examples are provided in `environments/commmon/layouts/` demonstrating a minimal appliance with only the Slurm cluster itself, and an appliance with all functionality.
- Optionally, group variable files in `group_vars/<group_name>/overrides.yml`, where the group names match the functional groups described above. These can be used to override the default configuration for each functionality, which are defined in `environments/common/inventory/group_vars/all/<group_name>.yml` (the use of `all` here is due to ansible's precedence rules).

Although most of the inventory uses the group convention described above there are a few special cases:
- The `control`, `login` and `compute` groups are special as they need to contain actual hosts rather than child groups, and so should generally be defined in the templated-out `hosts` file.
- The cluster name must be set on all hosts using `openhpc_cluster_name`. Using an  `[all:vars]` section in the `hosts` file is usually convenient.
- `environments/common/inventory/group_vars/all/defaults.yml` contains some variables which are not associated with a specific role/feature. These are unlikely to need changing, but if necessary that could be done using a `environments/<environment>/inventory/group_vars/all/overrides.yml` file.
- Each Slurm partition must have:
    - An inventory group `<cluster_name>_<partition_name>` defining the hosts it contains - these must be homogenous w.r.t CPU and memory.
    - An entry in the `openhpc_slurm_partitions` mapping in `environments/<environment>/inventory/group_vars/openhpc/overrides.yml`.
    See the [openhpc role documentation](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) for more options.


## Adding new functionality
TODO: this is just rough notes:
- Add new plays into existing playbook, or add a new playbook and update `site.yml`.
- Add new group into `environments/common/inventory/groups`
- Add new default group vars.
- Update example groups file `environments/common/layouts/everything`
- Update READMEs.
