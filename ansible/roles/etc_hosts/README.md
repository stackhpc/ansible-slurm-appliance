# etc_hosts

Populate `/etc/hosts` from ansible inventory. This is useful if internal DNS does not work.

# Requirements
None.

# Role Variables

`etc_hosts_template`: Jinja2 template to generate `IP_address canonical_hostname [aliases...]` lines in the `/etc/host` [file](https://man7.org/linux/man-pages/man5/hosts.5.html). The default assumes that `ansible_host` defines the IP address and `inventory_hostname` defines the canonical hostname. This may need overriding for multi-homed hosts. Note that this template must produce lines for all hosts when run on any host, hence the use of `hostvars` in the default.

# Dependencies
None.

# Example Playbook

```yaml
- hosts: etc_hosts
  gather_facts: false
  become: yes
  tags:
    etc_hosts
  tasks:
    - name: Manage /etc/hosts
      import_role:
        name: etc_hosts
```

# License
Apache 2.0

# Author Information
steveb@stackhpc.com
