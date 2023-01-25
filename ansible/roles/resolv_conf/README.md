# resolv_conf

Template out `/etc/resolv.conf`. If used, NetworkManager will be prevented from rewriting this file on boot.

## Role variables
- `resolv_conf_nameservers`: List of up to 3 nameserver addresses.

Note if `/etc/resolv.conf` includes `127.0.0.1` (e.g. due to a FreeIPA server installation), then `resolv_conf_nameservers` is ignored and this role does not change `/etc/resolv.conf`
