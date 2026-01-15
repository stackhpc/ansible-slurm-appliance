# mounts

Define custom mount points using fstab.

## Role vars

- `mounts_default`: Optional. Dict defining required mounts. Keys are arbitrary
  unique name for the mount. Values are a dict with the following possible
  entries:

  - `path`: Required string. Path to the mount point (created if necessary).
  - `src`: Required string. Device, NFS volume, etc, to be mounted on `path`.
  - `fstype`: Required string. Filesystem type.
  - `state`: Required string. Mount state e.g. `mounted`, `unmounted`.
  - `opts`: Optional string. Mount options. **NB:** These are exposed in logs.
  - `enabled`: Optional bool. Whether this mount definition is used. Default `true`.

  Except for `enabled`, all options are as for [ansible.posix/mount](https://docs.ansible.com/projects/ansible/latest/collections/ansible/posix/mount_module.html).

  The default value defines a mount `tmp` mounting a tmpfs to `/tmp`.

- `mounts_overrides`: Optional. Dict combined with (so overriding and/or
  extending) `mounts_default`, in same format.
- `mounts_tmp_enabled`: Optional. Bool defining if `tmp` mount is used. Default `true`.
- `mounts_tmp_size`: Optional. String with size of default `tmp` mount as for
  `size` in `man tmpfs`. Default `'10%'`.
- `mounts_tmp_opts`: Optional. String with mount options for default `tmp` mount.
  Default is as for `tmp.mount` unit except size defined by `mounts_tmp_size`.
