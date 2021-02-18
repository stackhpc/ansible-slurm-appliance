# Demos for OpenHPC on OpenStack

Example slurm configuration demonstrating a production/development split. This deploys
a battries included OpenHPC based slurm environment running on CentOS 8, along with
a monitoring stack.

## Pre-requisites

- Working DNS so that we can use the ansible inventory name as the address for connecting to services.

## Installation

    git clone  git@github.com:stackhpc/openhpc-demo.git
    cd openhpc-demo
    python3 -m venv venv
    . venv/bin/activate
    pip install -U pip
    pip install -r requirements.txt
    # Install ansible dependencies ...
    ansible-galaxy role install -r requirements.yml -p ansible/roles
    ansible-galaxy collection install -r requirements.yml -p ansible/collections

## Directory structure

NOTE: This is just an overview, please see the `README.md` in the relevant directory
for more details.

### environments

This repository contains the configuration for multiple different environments. The
configurations can be found in this directory.

### ansible

Prerequisite: You must have provisioned the infrastructure prior to running this step. See
`README.md` in environment folder for details.

Contains all the ansible playbooks to configure the infrastruture.

You must `activate` an environment prior to running any scripts.
This sets environment variables which allow the scripts to locate the
environment specific config. For example, to activate the `minimal` environment:

    source environments/minimal/activate
    ansible-playbook ansible/site.yml

### packer

Images for the compute nodes can be built in advance. This contains the packer
configuration to build the compute images. These can be used for upgrading an
existing cluster or for deploying the original set of compute nodes.

You must `activate` an environment prior to running any scripts.
This sets environment variables which allow the scripts to locate the
environment specific config. For example, to activate the `minimal` environment:

    source environments/minimal/activate
    cd packer
     ~/.local/bin/packer build --on-error=ask main.pkr.hcl

See `packer/README.md` for more details.
