[![Test deployment and image build on OpenStack](https://github.com/stackhpc/ansible-slurm-appliance/actions/workflows/stackhpc.yml/badge.svg)](https://github.com/stackhpc/ansible-slurm-appliance/actions/workflows/stackhpc.yml)

# StackHPC Slurm Appliance

This repository contains [Ansible](https://www.ansible.com/) playbooks and configuration to define a Slurm-based HPC environment including:
- A [RockyLinux](https://rockylinux.org/) 8.x and [OpenHPC](https://openhpc.community/) v2-based [Slurm](https://slurm.schedmd.com/) cluster with production-ready defaults for access, memory, etc.
- Shared fileystem(s), by default using NFS (optionally over RDMA).
- Slurm accounting using a [MySQL](https://www.mysql.com/) backend.
- Integrated monitoring providing per-job and per-node dashboards, using a [Prometheus](https://prometheus.io/) + [ElasticSearch](https://www.elastic.co/) + [Grafana](https://grafana.com/grafana/) stack.
- A [Packer](https://packer.io/) build pipeline for node images.

This repository is expected to be forked for a specific site and can contain multiple environments (e.g. development, staging and production). It has been designed to be modular and extensible, so if you add features for your HPC site please feel free to submit PRs to us!

Currently, the Slurm Appliance requires an [OpenStack](https://www.openstack.org/) cloud for full functionality, although it can be deployed on other clouds or unmanaged servers.

## Quickstart
This section demonstrates creating an Appliance with default configuration on VM instances with no floating IPs. See the full [Configuration](docs/configuration.md) guide for options.

Prerequsites:
- An OpenStack project with access to a RockyLinux 8.x GenericCloud image (or image based on that).
- A network and subnet in the project with routing for internet access.
- A RockyLinux 8.x instance on that network to be the "deploy host", with root access.
- An SSH keypair in OpenStack, with the private part on the deploy machine.
- OpenStack credentials on the deploy host.

Note that most of these can be relaxed with additional configuration.

1. Configure a deployment host (assuming RockyLinux 8.x):

        sudo yum install -y git python38
        git clone https://github.com/stackhpc/ansible-slurm-appliance # NB: consider forking this if not just a demo
        cd ansible-slurm-appliance
        . dev/setup-env

    This activates a Python virtualenv containing the required software - to reactivate later use:

        source venv/bin/activate

1. Create a new environment for your cluster:

        cd environments/
        cookiecutter skeleton

    And follow the prompts for the name and description

1. Activate the new environment:

        source environments/<environment>/activate

1. Configure Terraform for the target cloud:

    Modify `environments/<environment>/terraform/terraform.tfvars` following instructions in that file.

1. Install Terraform following instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).

1. Initialise Terraform:

        cd environments/<environment>/terraform/
        terraform init

1. Deploy instances:

        cd environments/<environment>/terraform
        terraform apply

1. Generate passwords:

        ansible-playbook ansible/adhoc/generate-passwords.yml

    This will output a set of passwords in `environments/<environment>/inventory/group_vars/all/secrets.yml`. For production use it is recommended that these are encrpyted and then commited to git using:

        ansible-vault encrypt inventory/group_vars/all/secrets.yml

    See the [Ansible vault documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for more details.

1. Deploy the appliance:

        ansible-playbook ansible/site.yml

   or if you have encrypted secrets use:

        ansible-playbook ansible/site.yml --ask-vault-password

You can now ssh into your cluster as user `rocky` - IP addresses will be listed in `environments/<environment>/inventory/hosts`. Note this cluster has an NFS-shared `/home` but the `rocky` user's home is `/var/lib/rocky`.
