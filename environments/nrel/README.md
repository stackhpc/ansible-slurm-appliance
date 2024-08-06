# NREL Slurm appliance - Environment-Specific README

This README covers the NREL-specific environments:
   - `nrel`: Shared base environment for other NREL environments - do not activate this.
   - `prod`: Production environment using VMs on AMD Epyc hypervisors with RoCE.
   - `vtest`: Test & development environment at NREL. Suitable for users.
   - `devel`: Development - bleeding-edge NREL development environment. No users here.
   - `lab`: Development environment for StackHPC on `sms-labs`, using VMs without RoCE.

This README is supplimentary to the main readme at ../../README.md so only differences/additinoal information is noted here. Paths are relative to the environment unless otherwise noted.

## Installation on deployment host
See main README.

Additionally install `terraform` following its [documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli).

## Overview of directory structure
See main README.

## Creating a Slurm appliance

In addition to main README:

2. Deploy infrastructure using Terraform:

   - Modify variables in `environments/<environment>/terraform/terraform.tfvars` to define the cluster size and cloud environment.
   - Ensure the appropriate images (Rocky Linux 8.x) and SSH keys are available in OpenStack.

   For the `lab` environment on `sms-labs` ONLY run:

         cd environments/lab/terraform/network
         terraform init
         terraform apply

   (this creates appropriate networking, which is preprovisioned in the other environments)

   For all environments run:

         cd environments/<environment>/terraform
         terraform apply

6. Spack can be installed, configured, and pre-determined packages installed by running:

        ansible-playbook ansible/spack.yml

   This installs Spack at `/nopt/spack` which is an NFS share from an external instance (which is not defined by this repo). See [Installing Software](#Installing-Software) below for more.

## Environments

TODO: update this section

This environment defines:

- 2x login nodes `nrel-login-{0,1}` - see `inventory/hosts` for IP addresses.
- 4x node "hpc" partition with 3-day timelimit. Intended to represent a partition for production MPI application runs.
- 2x node "express" partition with a 1-hour timelimit. Intended to represent a partition for development of (multi-node) MPI-based Python data science programs.
- Monitoring dashboards available via Grafana on `nrel-login-0` - use a SOCKS proxy as above to access this. Grafana can be used without login in read-only mode, or use username: `grafana` and password given in `inventory/group_vars/all/secrets.yml` to login in admin mode.
- All other services running on the Slurm controller `nrel-control`.
- `/home/` mounted over NFS from `nrel-control` on login and compute nodes (note `centos` and other system users have local home directories in `/var/lib/`).
- The following filesystems mounted over NFS on all hosts from a separate instance not managed by this environment (see `home/centos/nrel-filer/` on the deploy host for code):
    - `/scratch`: Cluster shared scratch
    - `/projects`: Cluster shared storage
    - `/nopt`: Network applications.
   These are intended to prototype CephFS-backed shared fileystems in the production environment.
- `/tmp/scratch` is provided on ephemeral disk as a prototype for an SSD-based volume in the production environment.

Note that non-privileged users cannot log into compute nodes unless they have a running job.

# Installing software

- Packages available from enabled repos (CentOS, OpenHPC, elrepo) can be installed on **all** cluster nodes by adding them to `openhpc_packages` in `environments/nrel-proto/inventory/group_vars/openhpc/overrides.yml`.
- Packages can be installed manually using spack commands into the spack installation in `/nopt`. Run `sudo su` first, rather than using `sudo spack install ...` due to the way paths etc are set up.
- Packages can be added to the automated spack install by adding specs to `spack_packages` in `environments/nrel-proto/inventory/group_vars/spack/overrides.yml`.
