[![Test deployment and image build on OpenStack](https://github.com/stackhpc/ansible-slurm-appliance/actions/workflows/stackhpc.yml/badge.svg)](https://github.com/stackhpc/ansible-slurm-appliance/actions/workflows/stackhpc.yml)

# StackHPC Slurm Appliance

This repository contains playbooks and configuration to define a Slurm-based HPC environment including:
- A Rocky Linux 9 and OpenHPC v3-based Slurm cluster.
- Shared fileystem(s) using NFS (with servers within or external to the cluster).
- Slurm accounting using a MySQL backend.
- A monitoring backend using Prometheus and ElasticSearch.
- Grafana with dashboards for both individual nodes and Slurm jobs.
- Production-ready Slurm defaults for access and memory.
- A Packer-based build pipeline for compute and login node images.

The repository is designed to be forked for a specific use-case/HPC site but can contain multiple environments (e.g. development, staging and production). It has been designed to be modular and extensible, so if you add features for your HPC site please feel free to submit PRs back upstream to us!

While it is tested on OpenStack it should work on any cloud, except for node rebuild/reimaging features which are currently OpenStack-specific.

## Prerequisites
It is recommended to check the following before starting:
- You have root access on the "ansible deploy host" which will be used to deploy the appliance.
- You can create instances using a Rocky 9 GenericCloud image (or an image based on that).
    - **NB**: In general it is recommended to use the [latest released image](https://github.com/stackhpc/ansible-slurm-appliance/releases) which already contains the required packages. This is built and tested in StackHPC's CI. However the appliance will install the necessary packages if a GenericCloud image is used.
- SSH keys get correctly injected into instances.
- Instances have access to internet (note proxies can be setup through the appliance if necessary).
- DNS works (if not this can be partially worked around but additional configuration will be required).
- Created instances have accurate/synchronised time (for VM instances this is usually provided by the hypervisor; if not or for bare metal instances it may be necessary to configure a time service via the appliance).

## Installation on deployment host

These instructions assume the deployment host is running Rocky Linux 8:

    sudo yum install -y git python38
    git clone https://github.com/stackhpc/ansible-slurm-appliance
    cd ansible-slurm-appliance
    ./dev/setup-env.sh

## Overview of directory structure

- `environments/`: Contains configurations for both a "common" environment and one or more environments derived from this for your site. These define ansible inventory and may also contain provisioning automation such as Terraform or OpenStack HEAT templates.
- `ansible/`: Contains the ansible playbooks to configure the infrastruture.
- `packer/`: Contains automation to use Packer to build compute nodes for an enviromment - see the README in this directory for further information.
- `dev/`: Contains development tools.

## Environments

### Overview

An environment defines the configuration for a single instantiation of this Slurm appliance. Each environment is a directory in `environments/`, containing:
- Any deployment automation required - e.g. Terraform configuration or HEAT templates.
- An ansible `inventory/` directory.
- An `activate` script which sets environment variables to point to this configuration.
- Optionally, additional playbooks in `/hooks` to run before or after the main tasks.

All environments load the inventory from the `common` environment first, with the environment-specific inventory then overriding parts of this as required.

### Creating a new environment

This repo contains a `cookiecutter` template which can be used to create a new environment from scratch. Run the [installation on deployment host](#Installation-on-deployment-host) instructions above, then in the repo root run:

    . venv/bin/activate
    cd environments
    cookiecutter skeleton

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
- The `ansible/adhoc/generate-passwords.yml` playbook sets secrets for all hosts in `environments/<environent>/inventory/group_vars/all/secrets.yml`.
- The Packer-based pipeline for building compute images creates a VM in groups `builder` and `compute`, allowing build-specific properties to be set in `environments/common/inventory/group_vars/builder/defaults.yml` or the equivalent inventory-specific path.
- Each Slurm partition must have:
    - An inventory group `<cluster_name>_<partition_name>` defining the hosts it contains - these must be homogenous w.r.t CPU and memory.
    - An entry in the `openhpc_slurm_partitions` mapping in `environments/<environment>/inventory/group_vars/openhpc/overrides.yml`.
    See the [openhpc role documentation](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) for more options.
- On an OpenStack cloud, rebuilding/reimaging compute nodes from Slurm can be enabled by defining a `rebuild` group containing the relevant compute hosts (e.g. in the generated `hosts` file).

## Creating a Slurm appliance

NB: This section describes generic instructions - check for any environment-specific instructions in `environments/<environment>/README.md` before starting.

1. Activate the environment - this **must be done** before any other commands are run:

        source environments/<environment>/activate

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

   Currently they include the following (see each playbook for links to documentation):
    - `hpctests.yml`: MPI-based cluster tests for latency, bandwidth and floating point performance.
    - `rebuild.yml`: Rebuild nodes with existing or new images (NB: this is intended for development not for reimaging nodes on an in-production cluster - see `ansible/roles/rebuild` for that).
    - `restart-slurm.yml`: Restart all Slurm daemons in the correct order.
    - `update-packages.yml`: Update specified packages on cluster nodes.

## Adding new functionality
Please contact us for specific advice, but in outline this generally involves:
- Adding a role.
- Adding a play calling that role into an existing playbook in `ansible/`, or adding a new playbook there and updating `site.yml`.
- Adding a new (empty) group named after the role into `environments/common/inventory/groups` and a non-empty example group into `environments/common/layouts/everything`.
- Adding new default group vars into `environments/common/inventory/group_vars/all/<rolename>/`.
- Updating the default Packer build variables in `environments/common/inventory/group_vars/builder/defaults.yml`.
- Updating READMEs.

## Monitoring and logging

Please see the [monitoring-and-logging.README.md](docs/monitoring-and-logging.README.md) for details.
