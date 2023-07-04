# etc_hosts

Hosts in the `etc_hosts` groups have `/etc/hosts` created with entries of the format `IP_address canonical_hostname [alias]`.

By default, an entry is created for each host in this group as follows:
- The value of `ansible_host` is used as the IP_address.
- If `node_fqdn` is defined then that is used as the canonical hostname and `inventory_hostname` as an alias. Otherwise `inventory_hostname` is used as the canonical hostname.
This may need overriding for multi-homed hosts or hosts with multiple aliases.

# Variables

- `etc_hosts_template`: Template file to use. Default is the in-role template.
- `etc_hosts_hostvars`: A list of variable names, used (in the order supplied) to create the entry for each host. Default is described above.
- `etc_hosts_extra_hosts`: String (possibly multi-line) defining additional hosts to add to `/etc/hosts`. Default is empty string.
