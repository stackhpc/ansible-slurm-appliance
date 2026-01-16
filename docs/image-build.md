# Packer-based image build

The appliance contains configuration to use [Packer](https://developer.hashicorp.com/packer)
with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack)
to build images. Using images:

- Enables the image to be tested in a `staging` environment before deployment
  to the `production` environment.
- Ensures re-deployment of the cluster or deployment of additional nodes is
  repeatable.
- Improves deployment speed by reducing the number of package installation.

The Packer configuration here can be used to build two types of images:

1. "Fat images" which contain packages, binaries and container images but no
   cluster-specific configuration. These start from a RockyLinux GenericCloud
   (or compatible) image. The fat images StackHPC builds and tests in CI are
   available from [GitHub releases](https://github.com/stackhpc/ansible-slurm-appliance/releases).
   However site-specific fat images can also be built from a different source
   image e.g. if a different partition layout is required.
2. "Extra-build" images which extend a fat image to create a site-specific
   image with with additional packages or functionality. For example the NVIDIA
   `cuda` packages cannot be redistributed hence require an "extra" build.

## Usage

For either a site-specific fat-image build or an extra-build:

1. Ensure the current OpenStack credentials have sufficient authorisation to
   upload images (this may or may not require the `member` role for an
   application credential, depending on your OpenStack configuration).
2. If package installs are required, add the provided dev credentials for
   StackHPC's "Ark" Pulp server to the `site` environment:

   ```yaml
   # environments/site/inventory/group_vars/all/dnf_repos.yml:
   dnf_repos_username: your-ark-username
   dnf_repos_password: "{{ vault_dnf_repos_password }}"
   ```

   ```yaml
   # environments/site/inventory/group_vars/all/dnf_repos.yml:
   dnf_repos_password: "your-ark-password"
   ```

   > [!IMPORTANT]
   > The latter file should be vault-encrypted.

   Alternatively, configure a [local Pulp mirror](experimental/pulp.md).

3. Create a Packer [variable definition file](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables#assigning-values-to-input-variables). It must specify at least the
   the following variables:

   ```hcl
   # environments/site/builder.pkrvars.hcl:
   flavor = "general.v1.small"                           # VM flavor to use for builder VMs
   networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
   source_image_name = "Rocky-9-GenericCloud-Base-9.4"   # Name of image to create VM with, i.e. starting image
   inventory_groups = "doca,cuda,extra_packages"         # Build VM inventory groups => functionality to add to image
   ```

   See the top of [packer/openstack.pkr.hcl](../packer/openstack.pkr.hcl)
   for all possible variables which can be set.

   Note that:
   - Normally the network must provide outbound internet access. However it
     does not need to provide access to resources used by the actual cluster
     nodes (e.g. Slurm control node, network filesystem servers etc.).
   - The flavor used must have sufficient memory for the build tasks (usually
     8GB), but otherwise does not need to match the actual cluster node
     flavor(s).
   - By default, the build VM is volume-backed to allow control of the root
     disk size (and hence final image size), so the flavor's disk size does not
     matter. The default volume size is not sufficient if enabling `cuda` and/or
     `doca` and should be increased:
     ```terraform
     volume_size = 35 # GB
     ```
   - The source image should be either:
     - For a site-specific fatimage build: A RockyLinux GenericCloud or
       compatible image.
     - For an extra-build image: Usually the appropriate StackHPC fat image,
       as defined in `environments/.stackhpc/tofu/cluster_image.auto.tfvars.json` at the
       checkout's current commit. See the [GitHub release page](https://github.com/stackhpc/ansible-slurm-appliance/releases)
       for download links. In some cases extra builds may be chained, e.g.
       one extra build adds a Lustre client, and the resulting image is used
       as the source image for an extra build adding GPU support.
   - The `inventory_groups` variable takes a comma-separated list of Ansible
     inventory groups to add the build VM to (in addition to the `builder`
     group which is it always in). This controls which Ansible roles and
     functionality run during build, and hence what gets added to the image.
     All possible groups are listed in `environments/common/groups` but common
     options for this variable will be:
     - For a fatimage build: `fatimage`: This is defined in `environments/site/inventory/groups`
       and results in an update of all packages in the source image, plus
       installation of packages for default control, login and compute nodes.

     - For an extra-built image, one or more specific groups. This extends the
       source image with just this additional functionality. The example above
       installs NVIDIA DOCA network drivers, NVIDIA GPU drivers/Cuda packages
       and also enables installation of packages defined in the
       `appliances_extra_packages_other` variable (see
       [docs/operations.md](./operations.md#adding-additional-packages)).

4. Activate the venv and the relevant environment.

5. Build images using the relevant variable definition file, e.g.:

   ```shell
   cd packer/
   PACKER_LOG=1 /usr/bin/packer build -on-error=ask -var-file=../environments/site/builder.pkrvars.hcl openstack.pkr.hcl
   ```

   **NB:** If the build fails while creating the volume, check if the source image has the `signature_verified` property:

   ```shell
   openstack image show $SOURCE_IMAGE
   ```

   If it does, remove this property:

   ```shell
   openstack image unset --property signature_verified $SOURCE_IMAGE
   ```

   then delete the failed volume, select cancelling the build when Packer asks,
   and then retry. This is [OpenStack bug 1823445](https://bugs.launchpad.net/cinder/+bug/1823445).

   The image name and UUID will be output near the end of a build, e.g.:

   ```shell
   ==> openstack.openhpc: Waiting for image openhpc-251017-1156-046b6133 (image id: 86ac2073-0a86-4fbf-935c-f1b6e6392e90) to become ready...
   ```

6. The built image will be automatically uploaded to OpenStack. By default it
   will have a name prefixed `openhpc` and including a timestamp and a shortened
   Git hash.

7. Set the image properties. From the repository root run:

   ```shell
   dev/image-set-properties.sh $IMAGE_NAME_OR_ID
   ```

## Build Process

In summary, Packer creates an OpenStack VM, runs Ansible on that, shuts it down, then creates an image from the root disk.

Many of the Packer variables defined in `openstack.pkr.hcl` control the definition of the build VM and how to SSH to it to run Ansible. These are generic OpenStack builder options
and are not specific to the Slurm Appliance. Packer variables can be set in a file at any convenient path; the build example above
shows the use of a path in the **site** environment. This is the most appropriate as builds should be tested in **dev** or **staging** before deployment to a production environment.

During stackhpc CI image builds, the environment variable `$PKR_VAR_environment_root` (which itself sets the Packer variable
`environment_root`) is used to automatically select a variable file from the current environment; see `.github/workflows/fatimage.yml`.

What is Slurm Appliance-specific are the details of how Ansible is run:

- The build VM is always added to the `builder` inventory group, which differentiates it from nodes in a cluster. This allows
  Ansible variables to be set differently during Packer builds, e.g. to prevent services starting. The defaults for this are in `environments/common/inventory/group_vars/builder/`, which could be extended or overridden for site-specific fat image builds using `builder` groupvars for the relevant environment. It also runs some builder-specific code (e.g. to clean up the image).
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
