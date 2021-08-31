Role Name
=========

Setup fail2ban to protect SSH on a host.

Note that no email alerts are set up so logs (at `/var/log/fail2ban.log`) will have to be manually reviewed if required.

Requirements
------------

A CentOS 8 system.

Role Variables
--------------

- `fail2ban_cluster_subnet`: Required. CIDR of cluster's subnet.
- `fail2ban_firewalld_configs`: Optional. List of dicts giving parameters for Ansible's [posix.firewalld](https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html) module. The default is to add `fail2ban_cluster_subnet` to the `trusted` zone so that no ports are blocked. This is the easiest way to comply with Slurm's networking requirements.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: fail2ban
  gather_facts: false
  become: yes
  tasks:
    - import_role:
        name: fail2ban
```

License
-------

Apache v2

Author Information
------------------

stackhpc.com
