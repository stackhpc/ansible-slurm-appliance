# Packer-based image build

The appliance contains code and configuration to use [Packer](https://developer.hashicorp.com/packer) with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build images.

The Packer configuration defined here builds "fat images" which contain packages, binaries and container images but no cluster-specific configuration. Using these:
- Enables the image to be tested in CI before production use.
- Ensures re-deployment of the cluster or deployment of additional nodes can be completed even if packages are changed in upstream repositories (e.g. due to RockyLinux or OpenHPC updates).
- Improves deployment speed by reducing the number of package downloads to improve deployment speed.

The fat images StackHPC builds and tests in CI are available from [GitHub releases](https://github.com/stackhpc/ansible-slurm-appliance/releases). However with some additional configuration it is also possible to:
1. Build site-specific fat images from scratch.
2. Extend an existing fat image with additional functionality.


# Usage

To build either a site-specific fat image from scratch, or to extend an existing StackHPC fat image:

1. Ensure the current OpenStack credentials have sufficient authorisation to upload images (this may or may not require the `member` role for an application credential, depending on your OpenStack configuration).
2. Create a Packer [variable definition file](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables#assigning-values-to-input-variables) at e.g. `environments/<environment>/builder.pkrvars.hcl` containing at a minimum:
  
    ```hcl
    flavor = "general.v1.small"                           # VM flavor to use for builder VMs
    networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
    source_image_name = "Rocky-9-GenericCloud-Base-9.4"   # Name of image to create VM with, i.e. starting image
    inventory_groups = "control,login,compute"            # Additional inventory groups to add build VM to

    ```

    Note that:
    - The network used for the Packer VM must provide outbound internet access but does not need to provide access to resources which the final cluster nodes require (e.g. Slurm control node, network filesystem servers etc.).
    - The flavor used must have sufficent memory for the build tasks, but otherwise does not need to match the final cluster nodes. Usually 8GB is sufficent. By default, the build VM is volume-backed to allow control of the root disk size (and hence final image size) so the flavor disk size does not matter.
    - The source image should be either a RockyLinux GenericCloud image for a site-specific image build from scratch, or a StackHPC fat image if extending an existing image.
    - The `inventory_groups` variable takes a comma-separated list of Ansible inventory groups to add the build VM to. This is in addition to the `builder` group which it is always added to. This controls which Ansible roles and functionality run during build, and hence what gets added to the image. All possible groups are listed in `environments/common/groups` but common options for this variable will be:
      - `update,control,login,compute`: The resultant image has all packages in the source image updated, and then packages for all types of nodes in the cluster are added. When using a GenericCloud image for `source_image_name` this builds a site-specific fat image from scratch.
      - One or more specific groups which are not enabled in the appliance by default, e.g. `lustre`. When using a StackHPC fat image for `source_image_name` this extends the image with just this additional functionality.

3. Activate the venv and the relevant environment.

4. Build images using the relevant variable definition file, e.g.:

        cd packer/
        PACKER_LOG=1 /usr/bin/packer build -on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

    **NB:** If the build fails while creating the volume, check if the source image has the `signature_verified` property:

        openstack image show $SOURCE_IMAGE

      If it does, remove this property:

          openstack image unset --property signature_verified $SOURCE_IMAGE

      then delete the failed volume, select cancelling the build when Packer queries, and then retry. This is [Openstack bug 1823445](https://bugs.launchpad.net/cinder/+bug/1823445).

5. The built image will be automatically uploaded to OpenStack with a name prefixed `openhpc` and including a timestamp and a shortened git hash.

# Build Process

In summary, Packer creates an OpenStack VM, runs Ansible on that, shuts it down, then creates an image from the root disk.

Many of the Packer variables defined in `openstack.pkr.hcl` control the definition of the build VM and how to SSH to it to run Ansible. These are generic OpenStack builder options
and are not specific to the Slurm Appliance. Packer varibles can be set in a file at any convenient path; the build example above
shows the use of the environment variable `$PKR_VAR_environment_root` (which itself sets the Packer variable
`environment_root`) to automatically select a variable file from the current environment, but for site-specific builds
using a path in a "parent" environment is likely to be more appropriate (as builds should not be environment-specific to allow testing before deployment to a production environment).

What is Slurm Appliance-specific are the details of how Ansible is run:
- The build VM is always added to the `builder` inventory group, which differentiates it from nodes in a cluster. This allows
  Ansible variables to be set differently during Packer builds, e.g. to prevent services starting. The defaults for this are in `environments/common/inventory/group_vars/builder/`, which could be extended or overriden for site-specific fat image builds using `builder` groupvars for the relevant environment. It also runs some builder-specific code (e.g. to clean up the image).
- The default fat image builds also add the build VM to the "top-level" `compute`, `control` and `login` groups. This ensures
  the Ansible specific to all of these types of nodes run. Note other inventory groups are constructed from these by `environments/common/inventory/groups file` - this is not builder-specific.
- As noted above, for "extra" builds the additional groups can be specified directly. In this way an existing image can be extended with site-specific Ansible, without modifying the
  part of the image which has already been tested in the StackHPC CI.
- The playbook `ansible/fatimage.yml` is run which is only a subset of `ansible/site.yml`. This allows restricting the code which runs during build for cases where setting `builder`
  groupvars is not sufficient (e.g. a role always attempts to configure or start services).

There are some things to be aware of when developing Ansible to run in a Packer build VM:
  - Only some tasks make sense. E.g. any services with a reliance on the network cannot be started, and should not be enabled if, when creating an instance with the resulting image, the remote service will not be immediately present.
  - Nothing should be written to the persistent state directory `appliances_state_dir`, as this is on the root filesystem rather than an OpenStack volume.
  - Care should be taken not to leave data on the root filesystem which is not wanted in the final image (e.g secrets).
  - Build VM hostnames are not the same as for equivalent "real" hosts and do not contain `login`, `control` etc. Therefore variables used by the build VM must be defined as groupvars not hostvars.
  - Ansible may need to use a proxyjump to reach cluster nodes, which can be defined via Ansible's `ansible_ssh_common_args` variable. If Packer should not use the same proxy
    to connect to build VMs (e.g. because build happens on a different network), this proxy configuration should not be added to the `all` group.
