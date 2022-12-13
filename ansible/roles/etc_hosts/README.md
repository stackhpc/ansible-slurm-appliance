# etc_hosts

Hosts in the `etc_hosts` groups have `/etc/hosts` created. The generated file defines all hosts in this group using `ansible_host` as the IP address and `inventory_hostname` as the canonical hostname. This may need overriding for multi-homed hosts. See `environments/common/inventory/group_vars/all/cloud_init.yml` for configuration.

# Variables:

- `etc_hosts_template`: Template file to use. Default uses in-role template.
