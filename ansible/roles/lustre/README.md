# lustre

Install and configure a Lustre client. This builds RPM packages from source.

**NB:** The `install.yml` playbook in this role should only be run during image build and is not idempotent. This will install the `kernel-devel` package; if not already installed (e.g. from an `ofed` installation), this may require enabling update of DNF packages during build using `update_enable=true`, which will upgrade the kernel as well.

**NB:** Currently this only supports RockyLinux 9.

## Role Variables

- `lustre_version`: Optional str. Version of lustre to build, default `2.15.5` which is the first version with EL9 support
- `lustre_lnet_label`: Optional str. The "lnet label" part of the host's NID, e.g. `tcp0`. Only the `tcp` protocol type is currently supported. Default `tcp`.
- `lustre_mgs_nid`: Required str. The NID(s) for the MGS, e.g. `192.168.227.11@tcp1` (separate mutiple MGS NIDs using `:`).
- `lustre_mounts`: Required list. Define Lustre filesystems and mountpoints as a list of dicts with keys:
    - `fs_name`: Required str. The name of the filesystem to mount
    - `mount_point`: Required str. Path to mount filesystem at.
    - `mount_state`: Optional mount state, as for [ansible.posix.mount](https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html#parameter-state). Default is `lustre_mount_state`.
    - `mount_options`: Optional mount options. Default is `lustre_mount_options`.
- `lustre_mount_state`. Optional default mount state for all mounts, as for [ansible.posix.mount](https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html#parameter-state). Default is `mounted`.
- `lustre_mount_options`. Optional default mount options. Default values are systemd defaults from [Lustre client docs](http://wiki.lustre.org/Mounting_a_Lustre_File_System_on_Client_Nodes).

The following variables control the package build and and install and should not generally be required:
- `lustre_build_packages`: Optional list. Prerequisite packages required to build Lustre. See `defaults/main.yml`.
- `lustre_build_dir`: Optional str. Path to build lustre at, default `/tmp/lustre-release`.
- `lustre_configure_opts`: Optional list. Options to `./configure` command. Default builds client rpms supporting Mellanox OFED, without support for GSS keys.
- `lustre_rpm_globs`: Optional list. Shell glob patterns for rpms to install. Note order is important as the built RPMs are not in a yum repo. Default is just the `kmod-lustre-client` and `lustre-client` packages.
- `lustre_build_cleanup`: Optional bool. Whether to uninstall prerequisite packages and delete the build directories etc. Default `true`.
