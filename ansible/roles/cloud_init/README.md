# cloud_init

Create cloud init userdata for instance groups.

# Requirements
Image and cloud environment supporting cloud-init.

# Role Variables

- `cloud_init_output_path`: Required. Path to output userdata files to.
- `cloud_init_userdata_templates`: Optional list. Each element is a dict with keys/values as follows:
    - `module`: Required str. Name of cloud_init [module](https://cloudinit.readthedocs.io/en/latest/topics/modules.html)
    - `group`: Optional str. Name of inventory group to which this config applies - if omitted it applies. This allows defining `cloud_init_userdata_templates` for group `all`.
    - `template`: Jinja template for cloud_init module [configuration](https://cloudinit.readthedocs.io/en/latest/topics/modules.html).

  Elements may repeat `module`; the resulting userdata cloud-config file will will contain configuration from all applicable (by group) elements for that module.
  
  Note that the appliance [constructs](../../../environments/common/inventory/group_vars/all/cloud_init.yml) `cloud_init_userdata_templates` from `cloud_init_userdata_templates_default` and `cloud_init_userdata_templates_extra` to 
  allow easier customisation in specific environments.

# Dependencies
None.

# Example Playbook
See `ansible/adhoc/rebuild.yml`.

# License
Apache 2.0

# Author Information
steveb@stackhpc.com
