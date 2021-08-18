Role Name
=========

Setup fail2ban to protect SSH on a host.

Note that no email alerts are set up so logs (at `/var/log/fail2ban.log`) will have to be manually reviewed if required.

Requirements
------------

A CentOS 8 system.

Role Variables
--------------

None.

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
