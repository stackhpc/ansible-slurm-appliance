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

### environments

Contains configurations for both a "common" environment and one or more environments derived from this for your site.

Environments define ansible inventory and may also contain provisioning code such as Terraform or OpenStack HEAT templates.

**NB:** All commands described below require an environment to be "activated" to set appropriate environment variables:

    source environments/<environment>activate

How to create and modify an environment is described below.

### ansible

Contains the ansible playbooks to configure the infrastruture.

Once an environment has been activated as above, the following will run all configuration:

    ansible-playbook ansible/site.yml

### packer

Images for the compute nodes can be built using the Packer in this director These can be used for upgrading an
existing cluster or for initial deployment of a set of compute nodes. Once an environment has been activated, run:

    cd packer
     ~/.local/bin/packer build --on-error=ask main.pkr.hcl

See `packer/README.md` for more details.
