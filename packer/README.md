# Packer-based image build

This workflow uses Packer with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build images. These images can be used to create or update a cluster. Using images speeds up cluster deploument and ensures that nodes are reproducable even if repository changes occur.

Packer creates OpenStack VMs and configures them by running `ansible/site.yml`, in the same way as for "direct configuration" of a cluster. However (by default) Packer builds set `update_enable: true` to run a `dnf update`. This is not the default for direct configuration to avoid modification of existing nodes. The Packer-build images will be uploaded to OpenStack with a name format of  `slurm-<nodetype>-<timestamp>`.

By default Packer builds images for `control`, `login` and `compute` nodes. TODO: indicate how to extend this.

## Compute images
By default (i.e. with no additional environment hooks etc.) these images are generic, i.e. they contain no configuration or secrets. These should be injected at boot time using cloud-init userdata - see TODO:. Building these images does not require any infrastructure to have been deployed. Nodes rebuilt with these images will join the cluster on boot.

TODO: Note that if NOT launched with metadata, the slurm-controlled rebuild will NOT work (as there is no metadata to provide config/secrets).

## Control and Login images
By default (i.e. with no additional environment hooks etc.) these images are not fully generic. Some configuration and secrets must be provided via cloud-init userdata as for compute nodes, but some is saved in the images. Building these images therefore requires some Ansible host/group variables to be set in inventory, which with the default Terraform-generated inventory requires control and login ports to deployed before building these images. Using the [appliance default](../environments/common/inventory/group_vars/all/defaults.yml) that hostnames are used for service addresses, these images may be moved between environments (e.g. dev/test/production) **if** hostnames are the same in all environments. **TODO** not sure this is true given IP addresses for openondemand??

Nodes rebuilt with a login node image (+ userdata) will rejoin the cluster on boot.

If a nodes is rebuild with a control node image (+ userdata), **or** any nodes are added to or removed from the cluster, the following plays must be run after boot of that control node:
- `ansible-playbook ansible/slurm.yml --tags openhpc` for Slurm partition configuration
- `ansible-playbook ansible/monitoring.yml` for Prometheus scrape configuration

# Build Process

- Create an application credential with sufficient authorisation to upload images (this may or may not be the `member` role, depending on your OpenStack configuration).
- Create a file `environments/<environment>/builder.pkrvars.hcl` containing at a minimum e.g.:
  
  ```hcl
  flavor = "general.v1.small"                           # VM flavor to use for builder VMs
  networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
  source_image_name = "Rocky-8.5-GenericCloud"          # Name of source image. This must exist in OpenStack and should be a Rocky Linux 8.5 GenericCloud-based image.
  ssh_keypair_name = "slurm-app-ci"                     # Name of an existing keypair in OpenStack. The private key must be on the host running Packer.
  ```
  
  The network(s) used for the Packer VMs must provide for outbound internet access but do not need to provide access to resources which the final cluster nodes require (e.g. Slurm control node, network filesystem servers etc.). These items are configured but not enabled in the Packer VMs.
  
  For additional options such as non-default private key locations or jumphost configuration see the variable descriptions in `./openstack.pkr.hcl`.

- Activate the venv and the relevant environment.
- Ensure you have generated passwords using:

        ansible-playbook ansible/adhoc/generate-passwords.yml

- Ensure you have the private part of the keypair `ssh_keypair_name` at `~/.ssh/id_rsa.pub` (or set variable `ssh_private_key_file` in `builder.pkrvars.hcl`).

- Build images:

        cd packer
        PACKER_LOG=1 /usr/bin/packer build -on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

To build only specific images use e.g. `-only openstack.compute`.

# Notes for developers

The Packer build VMs are added to both the `builder` group and the appropriate `login`, `compute` or `control` group. The former group allows `environments/common/inventory/group_vars/builder/defaults.yml` to set variables specifically for the Packer builds, e.g. for services which should not be started. However this **may** be overriden by specific environment group_vars definitions, depending on ordering. Therefore ansible extravars files are also provided in `packer/*.yml`.

Note that hostnames in the Packer VMs are not the same as the equivalent "real" hosts (this is deliberate to make it clearer when the Ansible running in the Packer build host is incorrectly trying to contact a "real" host). Therefore variables required inside a Packer VM must be defined as group vars, not hostvars.

Ansible may need to proxy to compute nodes. If the Packer build should not use the same proxy to connect to the builder VMs, note that proxy configuration should not be added to the `all` group.

**TODO:** tidy/move this:
When using appliance defaults and an environment with an `inventory/groups` file matching `environments/common/layouts/everything` (as used by cookiecutter for new environment creation), the following inventory variables must be defined when running Packer builds:
- `openhpc_cluster_name`
- `openondemand_servername`
- `inventory_hostname` for a host in the `control` group (provides `openhpc_slurm_control_host` and `nfs_server`)
