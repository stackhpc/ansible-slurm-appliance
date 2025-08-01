Role Name
=========

Install and configure the `firewalld` firewall.

Requirements
------------

EL8 host

Role Variables
--------------

- `firewalld_enabled`: Optional. Whether `firewalld` service is enabled (starts at boot). Default `yes`.
- `firewalld_state`: Optional. State of `firewalld` service. Default `started`. Other values: `stopped`.
- `firewalld_configs`: Optional. List of dicts giving parameters for [ansible.posix.firewalld module](https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html). Default is an empty list.

Note that the default configuration for firewalld on Rocky Linux 8.5 is as follows:
```shell
#  firewall-offline-cmd --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

Dependencies
------------

None.

Example Playbook
----------------

```
- hosts: firewalld
  gather_facts: false
  become: yes
  tags: firewalld
  tasks:
    - import_role:
        name: firewalld
```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
