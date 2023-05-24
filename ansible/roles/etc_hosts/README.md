# etc_hosts

Hosts in the `etc_hosts` groups have `/etc/hosts` created with entries of the format `IP_address canonical_hostname [alias]`.

By default, an entry is created for each host in this group, using `ansible_host` as the IP_address and `inventory_hostname` as the canonical hostname. This may need overriding for multi-homed hosts or hosts with multiple aliases.

# Variables

- `etc_hosts_template`: Template file to use. Default is the in-role template.
- `etc_hosts_hostvars`: A list of variable names, used (in the order supplied) to create the entry for each host. Default is `['ansible_host', 'inventory_hostname']`
- `etc_hosts_extra_hosts`: String (possibly multi-line) defining additional hosts to add to `/etc/hosts`. Default is empty string.
