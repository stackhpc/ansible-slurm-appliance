# resolv_conf

Template out `/etc/resolv.conf`.

## Role variables
- `resolv_conf_nameservers`: List of up to 3 nameserver addresses.

Notes:
- `NetworkManager` (if used) will be prevented from rewriting this file on boot.
- If `/etc/resolv.conf` includes `127.0.0.1` (e.g. due to a FreeIPA server installation), then `resolv_conf_nameservers` is ignored and this role does not change `/etc/resolv.conf`
- For hosts in the `resolv_conf` group, the `/etc/resolv.conf` created with `resolv_conf_nameservers` will
  NOT be deleted at the end of Packer image builds.
