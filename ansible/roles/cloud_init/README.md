# cloud_init

Create cloud init userdata for instance groups.

# Requirements
None

# Role Variables

- `cloud_init_output_path`: Optional str. Path to output userdata files to. Default `$APPLIANCES_ENVIRONMENT_ROOT/cloud_init/`.
- `cloud_init_userdata_template`: Optional str. Jinja2 template for [cloud-init userdata](https://cloudinit.readthedocs.io/en/latest/topics/format.html#user-data-formats). The default template creates `/etc/hosts` for nodes in the `etc_hosts` group.

# Dependencies
None.

# Example Playbook
See `ansible/adhoc/rebuild.yml`.

# License
Apache 2.0

# Author Information
steveb@stackhpc.com