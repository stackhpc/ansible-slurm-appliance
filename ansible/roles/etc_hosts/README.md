# etc_hosts

This role provides documentation only.

Hosts in the `etc_hosts` groups get `/etc/hosts` created via `cloud-init`. The generated file defines all hosts in this group using `ansible_host` as the IP address and `inventory_hostname` as the canonical hostname. This may need overriding for multi-homed hosts. See `environments/common/inventory/group_vars/all/cloud_init.yml` for configuration.
