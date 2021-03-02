# StackHPC Slurm Appliance

This repository contains playbooks and configuration to define a Slurm-based HPC environment, including:
- A Centos 8 and OpenHPC v2-based Slurm cluster with production-ready configuration.
- Shared fileystem(s using NFS (with servers within or external to the cluster).
- Slurm accounting using a MySQL backend.
- A monitoring backend using Prometheus and an ElasticSearch.
- Grafana with dashboards for both individual nodes and Slurm jobs.
- Production-ready Slurm defaults for access and memory.
- A Packer-based build pipeline for compute node images.

The repository is designed to be forked once for a specific use-case/HPC site containing multiple environments (e.g. development, staging and production). It has been designed to be modular and extensible, so if you add features for your HPC site please feel free to submit PRs back upstream to us!

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

Further information on each of these is provided in the relevent directory's `README.md`.

- `environments/`: Contains configurations for both a "common" environment and one or more environments derived from this for your site. These define ansible inventory and may also contain provisioning automation such as Terraform or OpenStack HEAT templates.
- `ansible/`: Contains the ansible playbooks to configure the infrastruture.
- `packer/`: Contains automation to use Packer to build compute nodes for an enviromment.

## Creating a Slurm appliance

NB: This section describes generic instructions - check for any environment-specific instructions in `environments/<environment>/README.md` before starting.

1. Activate the environment - this is REQUIRED before any other commands are run:

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


## Environments

An environment is a directory which defines all the configuration for instantiations of this Slurm appliance at one site. A cookiecutter command is described below provided to create a new environment from a template.

Amongst other things, an environments's `activate` script defines the path to a custom `ansible.cfg` which itself defines the paths to inventory directories. Therefore no inventory paths need to be specified to ansible once an environment is activated. All environments include `environments/common/inventory` as the first inventory searched, with the environment-specific inventory then overriding parts of this.

This repository generally follows a convention where:
- Functionality is defined in terms of ansible roles applied to a a group of the same name, e.g. `openhpc` or `grafana`. The empty groups in the `common` invenvory mean that functionality is disabled by default, and must be enabled for a specific environment by adding hosts or child groups to the group in an environment-specific `environments/<environment>/inventory/groups` file. The meaning of the groups is described below.
- Environment-specific variables for each role/group can be defined in a group_vars directory of the same name in `environments/<environment>/inventory/group_vars/<group_name>/overrides.yml`. These override any default values specified in `environments/common/inventory/group_vars/all/<group_name>.yml` (the use of `all` here is due to ansible's precedence rules).

TODO: Document hooks

### Creating a new environment

TODO: and  mention layout files.

### Modifying an environment

TODO:

### Environment-specific inventory

This section describes how to structure an environment

- The hosts should be listed in a file `environments/<environment>/inventory/hosts`. This is usually created by the deployment automation and should define the following groups:
    - `control`: A single host for the Slurm control node. Multiple (high availability) control nodes are not supported.
    - `login`: One or more hosts for Slurm login nodes. Combined control/login nodes are not supported.
    - `compute`: Hosts for all Slurm compute nodes.
- The cluster name must be defined for all hosts using `openhpc_cluster_name`. Setting this in the above hosts file using `[all:vars]` is usually convenient.
- Each Slurm partition must contain a homogeneous set of hosts. For each partition:
    - Define an ansible inventory group for each partition as `<cluster_name>_<partition_name>`.
    - Define the partition by setting openhpc_slurm_partitions in `environments/<environment>/inventory/group_vars/openhpc/overrides.yml`.
  
  See the [openhpc role documentation](https://github.com/stackhpc/ansible-role-openhpc#slurmconf) for more options.
