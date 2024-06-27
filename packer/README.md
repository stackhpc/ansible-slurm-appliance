# Packer-based image build

The appliance contains code and configuration to use [Packer](https://developer.hashicorp.com/packer) with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build images.

The Packer configuration defined here builds "fat images" which contain binaries for all nodes, but no cluster-specific configuration. Using these:
- Enables the image to be tested in CI before production use.
- Ensures re-deployment of the cluster or deployment of additional nodes can be completed even if packages are changed in upstream repositories (e.g. due to RockyLinux or OpenHPC updates).
- Improves deployment speed by reducing the number of package downloads to improve deployment speed.

By default, a fat image build starts from a RockyLinux GenericCloud image and updates all DNF packages already present.

The fat images StackHPC builds and test in CI are  available from [GitHub releases](https://github.com/stackhpc/ansible-slurm-appliance/releases). However with some additional configuration it is also possible to:
1. Build site-specific fat images from scratch.
2. Extend an existing fat image with additional software.


# Usage

The steps for building site-specific fat images or extending an existing fat image are the same:

1. Ensure the current OpenStack credentials have sufficient authorisation to upload images (this may or may not require the `member` role for an application credential, depending on your OpenStack configuration).
2. Create a Packer [variable definition file](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables#assigning-values-to-input-variables) at e.g. `environments/<environment>/builder.pkrvars.hcl` containing at a minimum e.g.:
  
    ```hcl
    flavor = "general.v1.small"                           # VM flavor to use for builder VMs
    networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
    ```
    
    - The network used for the Packer VM must provide outbound internet access but does not need to provide access to resources which the final cluster nodes require (e.g. Slurm control node, network filesystem servers etc.).
    
    - For additional options such as non-default private key locations or jumphost configuration see the variable descriptions in `./openstack.pkr.hcl`.

    - For an example of configuration for extending an existing fat image see below.

3. Activate the venv and the relevant environment.

4. Build images using the relevant variable definition file, e.g.:

        cd packer/
        PACKER_LOG=1 /usr/bin/packer build -only=openstack.openhpc --on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

  Note that the `-only` flag here restricts the build to the non-OFED fat image "source" (in Packer terminology). Other
  source options are:
    - `-only=openhpc-ofed`: Build a fat image including Mellanox OFED
    - `-only=openhpc-extra`: Build an image which extends an existing fat image - in this case the variable `source_image` or `source_image_name}` must also be set in the Packer variables file.
    
5. The built image will be automatically uploaded to OpenStack with a name prefixed `openhpc-` and including a timestamp and a shortened git hash.

# Build Process

In summary, Packer creates an OpenStack VM, runs Ansible on that, shuts it down, then creates an image from the root disk.

Many of the Packer variables defined in `openstack.pkr.hcl` control the definition of the build VM and how to SSH to it to run Ansible, which are generic OpenStack builder options. Packer varibles can be set in a file at any convenient path; the above
example shows the use of the environment variable `$PKR_VAR_environment_root` (which itself sets the Packer variable
`environment_root`) to automatically select a variable file from the current environment, but for site-specific builds
using a path in a "parent" environment is likely to be more appropriate (as builds should not be environment-specific, to allow testing).

What is Slurm Appliance-specific are the details of how Ansible is run:
- The build VM is always added to the `builder` inventory group, which differentiates it from "real" nodes. This allows
  variables to be set differently during Packer builds, e.g. to prevent services starting. The defaults for this are in `environments/common/inventory/group_vars/builder/`, which could be extended or overriden for site-specific fat image builds using `builder` groupvars for the relevant environment. It also runs some builder-specific code (e.g. to ensure Packer's SSH
  keys are removed from the image).
- The default fat image build also adds the build VM to the "top-level" `compute`, `control` and `login` groups. This ensures
  the Ansible specific to all of these types of nodes run (other inventory groups are constructed from these by `environments/common/inventory/groups file` - this is not builder-specific).
- Which groups the build VM is added to is controlled by the Packer `groups` variable. This can be redefined for builds using the `openhpc-extra` source to add the build VM into specific groups. E.g. with a Packer variable file:

      source_image_name = {
          RL9 = "openhpc-ofed-RL9-240619-0949-66c0e540"
      }
      groups = {
          openhpc-extra = ["foo"]
      }

    the build VM uses an existing "fat image" (rather than a RockyLinyux GenericCloud one) and is added to the `builder` and `foo` groups. This means only code targeting `builder` and `foo` groups runs. In this way an existing image can be extended with site-specific code, without modifying the part of the image which has already been tested in the StackHPC CI.

 - The playbook `ansible/fatimage.yml` is run which is only a subset of `ansible/site.yml`. This allows restricting the code
   which runs during build for cases where setting `builder` groupvars is not sufficient (e.g. a role always attempts to configure or start services). This may eventually be removed.

There are some things to be aware of when developing Ansible to run in a Packer build VM:
  - Only some tasks make sense. E.g. any services with a reliance on the network cannot be started, and may not be able to be enabled if when creating an instance with the resulting image the remote service will not be immediately present.
  - Nothing should be written to the persistent state directory `appliances_state_dir`, as this is on the root filesystem rather than an OpenStack volume.
  - Care should be taken not to leave data on the root filesystem which is not wanted in the final image, (e.g secrets).
  - Build VM hostnames are not the same as for equivalent "real" hosts and do not contain `login`, `control` etc. Therefore variables used by the build VM must be defined as groupvars not hostvars.
  - Ansible may need to proxy to real compute nodes. If Packer should not use the same proxy to connect to the
    build VMs (e.g. build happens on a different network), proxy configuration should not be added to the `all` group.
  - Currently two fat image "sources" are defined, with and without OFED. This simplifies CI configuration by allowing the
    default source images to be defined in the `openstack.pkr.hcl` definition.
