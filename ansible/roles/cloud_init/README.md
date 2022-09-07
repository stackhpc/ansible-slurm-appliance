# cloud_init

Create cloud init userdata for instance groups..

# Requirements
None

# Role Variables

- `cloud_init_userdata_templates`: Required, mapping a group name to the userdata template path (using normal Ansible template search paths).
- `cloud_init_output_path`: Required str. Path to output userdata files to.

# Dependencies
None.

# Example Playbook
See `ansible/adhoc/cloud_init.yml`. NB: Templating is done on a host created in the appropriate group, so group_names and hostvars will be set appropriately, 
even if inventory actually has no hosts in that group.

# License
Apache 2.0

# Author Information
steveb@stackhpc.com
