# mounts

Define custom mount points using fstab.

## Role vars

- `mounts_default`: Optional. Dict defining required mounts. Keys are arbitrary
  unique name for the mount. Values are a dict with the following entries, all
  as per parameters for [ansible.posix/mount](https://docs.ansible.com/projects/ansible/latest/collections/ansible/posix/mount_module.html):
    - `path`: Required string
    - `src`: Required string
    - `fstype`: Required string
    - `state`: Required string
    - `opts`: Optional string
  The default defines a mount `tmp` mounting a tmpfs to `/tmp`.
- `mounts_overrides`: Optional. Dict as for `mounts_default`, combined with this. Default empty.
- `mounts_tmp_size`: Optional. String with size of default `tmp` mount as for `size` in `man tmpfs`. Default `'10%'`.
- `mounts_tmp_opts`: Optional. String with mount options for default `tmp` mount. Default is as for `tmp.mount` unit except size defined by `mounts_tmp_size`.
