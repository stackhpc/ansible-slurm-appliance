# etc_hosts

Hosts in the `etc_hosts` groups have `/etc/hosts` created with entries of the format `IP_address canonical_hostname [alias]`.

By default, an entry is created for each host in this group, using `ansible_host` as the IP_address and `inventory_hostname` as the canonical hostname. This may need overriding for multi-homed hosts.

# Variables

- `etc_hosts_template`: Template file to use. Default is the in-role template.
- `etc_hosts_hosts`: Hosts to create an entry for in `/etc/hosts`. Default is hosts in the group `etc_hosts`. NB: this is different from the hosts on which `/etc/hosts` is created, which is always the hosts in the `etc_hosts` group. This allows additional hosts to be added to `/etc/hosts` by defining them in inventory and referencing them in this variable.
- `etc_hosts_hostvars`: A list of variable names, used (in the order supplied) to create the entry for each host. Default is `['ansible_host', 'inventory_hostname']`
