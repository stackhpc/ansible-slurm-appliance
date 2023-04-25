EESSI
=====

Configure the EESSI pilot respository for use on given hosts.

Requirements
------------

None.

Role Variables
--------------

- `cvmfs_quota_limit_mb`: Optional int. Maximum size of local package cache on each node in MB.
- `cvmfs_config_overrides`: Optional dict. Set of key-value pairs for additional CernVM-FS settings see [official docs](https://cvmfs.readthedocs.io/en/stable/cpt-configure.html) for list of options. Each dict key should correspond to a valid config variable (e.g. `CVMFS_HTTP_PROXY`) and the corresponding dict value will be set as the variable value (e.g. `https://my-proxy.com`). These configuration parameters will be written to the `/etc/cvmfs/default.local` config file on each host in the form `KEY=VALUE`.

Dependencies
------------

None.

Example Playbook
----------------

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
