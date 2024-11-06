[![Test deployment and image build on OpenStack](https://github.com/stackhpc/ansible-slurm-appliance/actions/workflows/stackhpc.yml/badge.svg)](https://github.com/stackhpc/ansible-slurm-appliance/actions/workflows/stackhpc.yml)

# StackHPC Slurm Appliance

This repository contains playbooks and configuration to define a Slurm-based HPC environment. This includes:
- [Rocky Linux](https://rockylinux.org/)-based hosts.
- [OpenTofu](https://opentofu.org/) configurations to define the cluster's infrastructure-as-code.
- Packages for Slurm and MPI software stacks from [OpenHPC](https://openhpc.community/).
- Shared fileystem(s) using NFS (with in-cluster or external servers) or [CephFS](https://docs.ceph.com/en/latest/cephfs/) via [Openstack Manila](https://wiki.openstack.org/wiki/Manila).
- Slurm accounting using a MySQL database.
- Monitoring integrated with Slurm jobs using Prometheus, ElasticSearch and Grafana.
- A web-based portal from [OpenOndemand](https://openondemand.org/).
- Production-ready default Slurm configurations for access and memory limits.
- [Packer](https://developer.hashicorp.com/packer)-based image build configurations for node images.

The repository is expected to be forked for a specific HPC site but can contain multiple environments for e.g. development, staging and production clusters
sharing a common configuration. It has been designed to be modular and extensible, so if you add features for your HPC site please feel free to submit PRs
back upstream to us!

While it is tested on OpenStack it should work on any cloud with appropriate OpenTofu configuration files.

## Demonstration Deployment

The default configuration in this repository may be used to create a cluster to explore use of the appliance. It provides:
- Persistent state backed by an OpenStack volume.
- NFS-based shared file system backed by another OpenStack volume.

Note that the OpenOndemand portal and its remote apps are not usable with this default configuration.

It requires an OpenStack cloud, and an Ansible "deploy host" with access to that cloud.

Before starting ensure that:
- You have root access on the deploy host.
- You can create instances using a Rocky 9 GenericCloud image (or an image based on that).
    - **NB**: In general it is recommended to use the [latest released image](https://github.com/stackhpc/ansible-slurm-appliance/releases) which already contains the required packages. This is built and tested in StackHPC's CI. However the appliance will install the necessary packages if a GenericCloud image is used.
- You have a SSH keypair defined in OpenStack, with the private key available on the deploy host.
- Created instances have access to internet (note proxies can be setup through the appliance if necessary).
- Created instances have accurate/synchronised time (for VM instances this is usually provided by the hypervisor; if not or for bare metal instances it may be necessary to configure a time service via the appliance).

### Setup deploy host

The following operating systems are supported for the deploy host:

- Rocky Linux 9
- Rocky Linux 8

These instructions assume the deployment host is running Rocky Linux 8:

    sudo yum install -y git python38
    git clone https://github.com/stackhpc/ansible-slurm-appliance
    cd ansible-slurm-appliance
    ./dev/setup-env.sh

You will also need to install [OpenTofu](https://opentofu.org/docs/intro/install/rpm/).

### Create a new environment

Use the `cookiecutter` template to create a new environment to hold your configuration. In the repository root run:

    . venv/bin/activate
    cd environments
    cookiecutter skeleton

and follow the prompts to complete the environment name and description.

**NB:** In subsequent sections this new environment is refered to as `$ENV`.

Now generate secrets for this environment:

    ansible-playbook ansible/adhoc/generate-passwords.yml

### Define infrastructure configuration

Create an OpenTofu variables file to define the required infrastructure, e.g.:

    # environments/$ENV/terraform/terraform.tfvars:

    cluster_name = "mycluster"
    cluster_net = "some_network" # *
    cluster_subnet = "some_subnet" # *
    key_pair = "my_key" # *
    control_node_flavor = "some_flavor_name"
    login_nodes = {
        login-0: "login_flavor_name"
    }
    cluster_image_id = "rocky_linux_9_image_uuid"
    compute = {
        general = {
            nodes: ["compute-0", "compute-1"]
            flavor: "compute_flavor_name"
        }
    }

Variables marked `*` refer to OpenStack resources which must already exist. The above is a minimal configuration - for all variables
and descriptions see `environments/$ENV/terraform/terraform.tfvars`.

### Deploy appliance

    ansible-playbook ansible/site.yml

You can now log in to the cluster using:

    ssh rocky@$login_ip

where the IP of the login node is given in `environments/$ENV/inventory/hosts.yml`


## Overview of directory structure

- `environments/`: See [docs/environments.md](docs/environments.md).
- `ansible/`: Contains the ansible playbooks to configure the infrastruture.
- `packer/`: Contains automation to use Packer to build machine images for an enviromment - see the README in this directory for further information.
- `dev/`: Contains development tools.

For further information see the [docs](docs/) directory.
