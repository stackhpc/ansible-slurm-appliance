# lustre

Install and configure a Lustre client. This builds RPM packages from source.

**NB:** The `install.yml` playbook in this role should only be run during image build, with the default `update_enable=true`. This ensures that the latest kernel and matching
`kernel-devel` packages will be installed. This playbook is not idempotent.

## Role Variables

- `lustre_version`: Optional str. Version of lustre to build, default '2.15.64'. TODO: EXPLAIN. See https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix
- `lustre_mounts`: Required list. Define Lustre filesystems and mountpoints as a list of dicts with possible keys:
    - `mgs_nid`: The NID for the MGS, e.g. `192.168.227.11@tcp1`
    - `fs_name`: The name of the filesystem to mount
    - `mount_point`: Path to mount filesystem at. Default is `/mnt/lustre/{{ lustre_fs_name}}`
    - `mount_state`: Mountpoint state, as for [ansible.posix.mount](https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html#parameter-state). Default `mounted`.
  Any of these parameters may alternatively be specified as role variables prefixed `lustre_`. If both are given entries in `lustre_mounts` take priority.

The following variables control the package build and and install and should not generally be required:
- `lustre_build_packages`: Optional list. Prerequisite packages required to build Lustre. See `defaults/main.yml`.
- `lustre_build_dir`: Optional str. Path to build lustre at, default `/tmp/lustre-release`.
- `lustre_configure_opts`: Optional list. Options to `./configure` command. Default builds client rpms supporting Mellnox OFED, without support for GSS keys. See `defaults/main.yml`.
- `lustre_rpm_globs`: Optional list. Shell glob patterns for rpms to install. Note order is important as the built RPMs are not in a yum repo. Default is just the `kmod-lustre-client` and `lustre-client` packages.
- `lustre_cleanup_build`: Optional bool. Whether to uninstall prerequisite packages and delete the build directories etc. Default `true`.
