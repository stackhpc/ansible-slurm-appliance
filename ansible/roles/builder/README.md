# builder

Define configuration for image builds using Packer and optionally `cloud-init` userdata to launch the built images with.

# Variables

**NB:** These variables must be defined for the `all` group so they are available to localhost running the Packer build:
- `builder_dir`: Required. Directory to use for build.
- `builder_images`: Required. Images and possibly cloudinit userdata to create, default `['control', 'login', 'compute']`. Names must also be inventory groups, and must be children of the default groups. 
- `builder_playbook_file`: Required. Path to playbook file to run inside VM.

**NB:** The Packer build host for each `<name>` build in `builder_images` is added to inventory groups as follows:
- `<name>` (e.g. `compute`): Used to inherit the group_vars for the particular type of image to be built.
- `builder`: Can be used to override variables for all builds.
- `builder_<name>` (e.g. `builder_compute`): Can be used to override variables for for specific builds if `ansible_group_priority` is set appropriately - see the default `builder_{control,login,compute}` groups in WHERE.

- `builder_openstack_defaults`: Required. Dict with name/values for the Packer OpenStack builder plugin, see https://www.packer.io/plugins/builders/openstack.
- `builder_openstack_overrides`: Optional. Merged with `builder_openstack_default`, can be used to override default values (e.g. for specific images).
- `builder_cloudinit_userdata`: Optional. Path to a Jinja2 template file to generate `cloud-init` user-data (probably cloud-config format).

Rebuild script should then MATCH group_names for instance againt avaialble user_data scripts and 

# Example

TODO:
