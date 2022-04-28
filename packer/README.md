# Packer-based image build

This workflow uses Packer with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build images. These images can be used during cluster creation or to update an existing cluster. Building images reduces the number of package downloads when deploying a large cluster, and ensures that nodes can be recreated even if packages are changed in repositories (e.g. due to Rocky Linux or OpenHPC updates).

Packer creates OpenStack VMs and configures them by running `ansible/site.yml` in the same way as for direct configuration of instances using Ansible. However (by default) in Packer builds a `yum update *` step is run. This is not the default for direct configuration, to avoid modifying existing nodes. Packer will upload the resulting images to OpenStack with a name which includes a timestamp.

Building images is likely to require Ansible host/group variables to be set in inventory to provide required configuration information. This may (depending on the inventory generation approach) require nodes to deployed before building images. See developer notes below for more information.

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

- Build images using the variable definition file:

        cd packer
        PACKER_LOG=1 /usr/bin/packer build -on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

  Note the builder VMs are added to the `builder` group to differentiate them from "real" nodes - see developer notes below.

This will build images for the `compute`, `login` and `control` ansible groups. To add additional builds add a new `source` in `openstack.pkr.hcl`.

To build only specific images use e.g. `-only openstack.login`.

Instances using built compute and login images should immediately join the cluster, as long as they are in the Slurm configuration. If reimaging existing nodes, consider doing this via Slurm - see [stackhpc.slurm_openstack_tools.rebuild/README.md](../ansible/collections/ansible_collections/stackhpc/slurm_openstack_tools/roles/rebuild/README.md).

Instances using built control images will require re-running the `ansible/site.yml` playbook on the entire cluster, as the following aspects cannot be configured inside the image:
- Slurm configuration (the "slurm.conf" file)
- Grafana dashboard import (assuming default use of control node for Grafana)
- Prometheus scrape configuration (ditto)

# Notes for developers

The Packer build VMs are added to both the `builder` group and the appropriate `login`, `compute` or `control` group. The former group allows `environments/common/inventory/group_vars/builder/defaults.yml` to set variables specifically for the Packer builds, e.g. for services which should not be started.

Note that hostnames in the Packer VMs are not the same as the equivalent "real" hosts. Therefore variables required inside a Packer VM must be defined as group vars, not hostvars.

Ansible may need to proxy to compute nodes. If the Packer build should not use the same proxy to connect to the builder VMs, note that proxy configuration should not be added to the `all` group.

When using appliance defaults and an environment with an `inventory/groups` file matching `environments/common/layouts/everything` (as used by cookiecutter for new environment creation), the following inventory variables must be defined when running Packer builds:
- `openhpc_cluster_name`
- `openondemand_servername`
- `inventory_hostname` for a host in the `control` group (provides `openhpc_slurm_control_host` and `nfs_server`)
