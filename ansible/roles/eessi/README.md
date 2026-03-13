# EESSI

Configure the EESSI pilot respository for use on given hosts.

## Requirements

None.

## Role Variables

All variables relate to [CernVM-FS configuration](https://cvmfs.readthedocs.io/en/stable/cpt-configure.html).
By default, the configuration is that [recommended by EESSI for single clients](https://www.eessi.io/docs/getting_access/native_installation/#installation-for-single-clients).
However if `cvmfs_http_proxy` is set to a non-empty string then a configuration
suitable for using a [squid proxy](https://www.eessi.io/docs/getting_access/native_installation/#configuring-your-client-to-use-a-squid-proxy)
is applied instead. See [docs/production](../../../docs/eessi.md#eessi-proxy-configuration)
for guidance on appliance configuration.

- `cvmfs_quota_limit_mb`: Optional int. Maximum size of local package cache on
  each node in MB. Default 10GB.
- `cvmfs_http_proxy`: Optional string. Value for [CVMFS_HTTP_PROXY](https://cvmfs.readthedocs.io/en/stable/cpt-configure.html#proxy-lists). Quotes are added around the provided value. Default empty string.
- `cvmfs_config_overrides`: Optional dict. Set of key-value pairs for additional
  CernVM-FS settings, written to `/etc/cvmfs/default.local`. Keys are
  [CVMFS configuration options](https://cvmfs.readthedocs.io/en/stable/cpt-configure.html)
  (e.g. `CVMFS_TIMEOUT_DIRECT`). Default empty dict.

## Dependencies

None.

## Example Playbook

```yaml
- name: Setup EESSI
  hosts: eessi
  tags: eessi
  become: true
  tasks:
    - name: Install and configure EESSI
      import_role:
        name: eessi
```
