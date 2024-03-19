# Packer-based image build

The appliance contains code and configuration to use Packer with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build images.

The image built is referred to as a "fat" image as it contains binaries for all nodes, but no configuration. Using a "fat" image:
- Enables the image to be tested in CI before production use.
- Ensures re-deployment of the cluster or deployment of additional nodes can be completed even if packages are changed in upstream repositories (e.g. due to RockyLinux or OpenHPC updates).
- Improves deployment speed by reducing the number of package downloads to improve deployment speed.

A default fat image is built in StackHPC's CI workflow and made available to clients. However it is possible to build site-specific fat images if required.

A fat image build starts from a RockyLinux GenericCloud image and (by default) updates all dnf packages in that image.

# Build Process
- Ensure the current OpenStack credentials have sufficient authorisation to upload images (this may or may not require the `member` role for an application credential, depending on your OpenStack configuration).
- Create a file `environments/<environment>/builder.pkrvars.hcl` containing at a minimum e.g.:
  
  ```hcl
  flavor = "general.v1.small"                           # VM flavor to use for builder VMs
  networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
  source_image_name = "Rocky-8.9-GenericCloud"          # Name of source image. This must exist in OpenStack and should be a Rocky Linux GenericCloud-based image.
  ```
  
  This configuration will generate and use an ephemeral SSH key for communicating with the Packer VM. If this is undesirable, set `ssh_keypair_name` to the name of an existing keypair in OpenStack. The private key must be on the host running Packer, and its path can be set using `ssh_private_key_file`.

  The network used for the Packer VM must provide outbound internet access but does not need to provide access to resources which the final cluster nodes require (e.g. Slurm control node, network filesystem servers etc.).
  
  For additional options such as non-default private key locations or jumphost configuration see the variable descriptions in `./openstack.pkr.hcl`.

- Activate the venv and the relevant environment.

- Build images using the relevant variable definition file:

        cd packer
        PACKER_LOG=1 /usr/bin/packer build -only openstack.openhpc --on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

  Note the build VM is added to the `builder` group to differentiate them from "real" nodes - see developer notes below.

- The built image will be automatically uploaded to OpenStack with a name prefixed `openhpc-` and including a timestamp and a shortened git hash.

# Notes for developers

Packer build VMs are added to both the `builder` group and the other top-level groups (e.g. `control`, `compute`, etc.). The former group allows `environments/common/inventory/group_vars/builder/defaults.yml` to set variables specifically for the Packer builds, e.g. for services which should not be started.

Note that hostnames in the Packer VMs are not the same as the equivalent "real" hosts. Therefore variables required inside a Packer VM must be defined as group vars, not hostvars.

Ansible may need to proxy to compute nodes. If the Packer build should not use the same proxy to connect to the builder VMs, note that proxy configuration should not be added to the `all` group.
