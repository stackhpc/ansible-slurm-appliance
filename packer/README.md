# Packer-based image build

The appliance contains code and configuration to use Packer with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build images. Two types of images can be built:

1. A "fat" image, containing binaries for all nodes, but no configuration. By default, this is done in StackHPC's CI workflow and the image made available to clients. The fat image is intended to be used as the base image for a cluster. This:
    - Ensures the cluster is using binaries which have been tested in CI.
    - Ensures deployment and further image builds can be completed even if packages are changed in upstream repositories (e.g. due to Rocky Linux or OpenHPC updates).
    - Reduces the number of package downloads to improve deployment speed.

    This build starts from a RockyLinux GenericCloud image and runs yum update.

2. An environment-specific compute node image, which additionally contains all configuration etc. to allow an instance booted with such an image to join a cluster. This allows Slurm to be used to reimage compute nodes for upgrades, see [stackhpc.slurm_openstack_tools.rebuild/README.md](../ansible/collections/ansible_collections/stackhpc/slurm_openstack_tools/roles/rebuild/README.md). This build starts from a "fat" image and does not run yum update.

# Build Process

Building an environment-specific compute node image will[^1] require a cluster to be provisioned to complete the Ansible host/group variables in inventory for the environment.

- Ensure the current OpenStack credentials have sufficient authorisation to upload images (this may or may not require the `member` role for an application credential, depending on your OpenStack configuration).
- Create a file `environments/<environment>/builder.pkrvars.hcl` containing at a minimum e.g.:
  
  ```hcl
  flavor = "general.v1.small"                           # VM flavor to use for builder VMs
  networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
  source_image_name = "Rocky-8.5-GenericCloud"          # Name of source image. This must exist in OpenStack and should be a Rocky Linux 8.5 GenericCloud-based image.
  ```
  
  This configuration will generate and use an ephemeral SSH key for communicating with the Packer VM. If this is undesirable, set `ssh_keypair_name` to the name of an existing keypair in OpenStack. The private key must be on the host running Packer, and its path can be set using `ssh_private_key_file`.

  The network used for the Packer VM must provide outbound internet access but does not need to provide access to resources which the final cluster nodes require (e.g. Slurm control node, network filesystem servers etc.).
  
  For additional options such as non-default private key locations or jumphost configuration see the variable descriptions in `./openstack.pkr.hcl`.

- Activate the venv and the relevant environment.
- Ensure you have generated passwords using:

        ansible-playbook ansible/adhoc/generate-passwords.yml

- Ensure you have the private part of the keypair `ssh_keypair_name` at `~/.ssh/id_rsa.pub` (or set variable `ssh_private_key_file` in `builder.pkrvars.hcl`).

- Build images using the variable definition file:

        cd packer
        PACKER_LOG=1 /usr/bin/packer build -except openstack.openhpc --on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

  Note the builder VMs are added to the `builder` group to differentiate them from "real" nodes - see developer notes below.

- The built image will be automatically uploaded to OpenStack with a name prefixed `ohpc-` and including a timestamp and a shortened git hash.

[^1]: With the default Terraform at least.

# Notes for developers

Packer build VMs are added to both the `builder` group and other groups (e.g. `compute`) as appropriate. The former group allows `environments/common/inventory/group_vars/builder/defaults.yml` to set variables specifically for the Packer builds, e.g. for services which should not be started.

Note that hostnames in the Packer VMs are not the same as the equivalent "real" hosts. Therefore variables required inside a Packer VM must be defined as group vars, not hostvars.

Ansible may need to proxy to compute nodes. If the Packer build should not use the same proxy to connect to the builder VMs, note that proxy configuration should not be added to the `all` group.

When using appliance defaults and an environment with an `inventory/groups` file matching `environments/common/layouts/everything` (as used by cookiecutter for new environment creation), the following inventory variables must be defined when running Packer builds:
- `openhpc_cluster_name`
- `openondemand_servername`
- `inventory_hostname` for a host in the `control` group (provides `openhpc_slurm_control_host` and `nfs_server`)
