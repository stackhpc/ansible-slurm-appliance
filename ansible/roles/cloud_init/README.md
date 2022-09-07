# cloud_init

Create cloud init userdata for instance groups.

# Requirements
None

# Role Variables

- `cloud_init_userdata_templates`: Required, mapping of group name (e.g. `compute`) to path to userdata template (in normal Ansible template search paths).
- `cloud_init_output_path`: Required str. Path to output userdata files to.

# Dependencies
None.

# Example Playbook
See `ansible/adhoc/cloud_init.yml`.

# License
Apache 2.0

# Author Information
steveb@stackhpc.com
