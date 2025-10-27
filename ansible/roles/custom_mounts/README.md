custom_mounts
=====

This Ansible role automates the mounting of CIFS, NFS, and CephFS/Ceph RBD, using either fstab or autofs.

Requirements
------------

None.

Role Variables
--------------

- `ceph_mt_conf_src_dir`: Path to the Ceph `.conf` file. Default: `{{ role_path }}/files`
- `ceph_common_version`: Version of Ceph to install. Default: `"2:19.2.2"`. If set to `false`, the latest version will be installed. Ceph will not be updated if already installed.
- `ceph_repo_release`: Ceph repository release name corresponding to the version. Default: `squid`. Ceph will not be updated if already installed.

- `custom_mounts`: Mounts are defined in a dictionary format. Each key represents a unique mount configuration. The role supports multiple mount types and methods, each with specific requirements and behaviors.

```yaml
custom_mounts:
  <mount_name>:                  # Arbitrary unique name for the mount
    method: <fstab|autofs>
    type: <cifs|nfs|cephfs|ceph_rbd>
    fs_path: <source_path>
    mount_point: <target_path>
    [master_mount_point]: <autofs base path>  # optional autofs only
    [autofs_options]: <autofs map options>    # optional autofs only
    fs_name: <ceph cluster name>              # ceph only
    pool_name: <rbd.pool.name>                # ceph_rdb only
    image_name: <rdb_image>                   # ceph_rdb only
    fstype: <xfs|ext4>                        # ceph_rdb only
    credentials:                              # cifs or ceph
      username: <user>                        # cifs only
      password: <pass>                        # cifs only
      domain: <domain>                        # cifs only
      file_path: <path to credential file>    # cifs only
      client_name: <client_name>              # ceph only      
      secret: <ceph client key>               # ceph only
      ceph_conf: <ceph.conf name>             # optional ceph only
    [mount_owner]: <owner>                    # optional fstab only
    [mount_group]: <group>                    # optional fstab only
    [mount_mode]: <permissions>               # optional fstab only
    [mount_opts]: <mount options>             # optional
    [state]: <mounted|unmounted>              # optional fstab only
    [dump]: <0|1>                             # optional fstab only
    [passno]: <0|1>                           # optional fstab only
```

Mount Type Differences
----------------------

1. **CIFS/SMB** `type: cifs` (Windows-style network shares)
- Compatible with method: **autofs** and **fstab**.
- Requires `fs_path` in UNC format: `//host/share`.
- Requires a `credentials:` section (`username`, `password`, `domain`, `file_path`).
  - Credentials are stored in a file and referenced via `file_path`.
- Mount options may include `vers`, `uid`, `gid`, `mfsymlinks`, etc.
- Credentials are stored in a file and referenced via `file_path`.
  - If `master_mount_point` is not used, the base directory of `fs_path` is used as `master_mount_point`.
- When method: **autofs**, 
  - If `master_mount_point` is used, the `fs_path` is treated as a sub-location inside `master_mount_point`.
  - `autofs_options` are optional to be added to `/etc/auto.master.d/mountkey.autofs` e.g. `--timeout 60`
  -  Mount points settings `mount_owner`, `mount_group`, `mount_mode` will not persist after autofs mounting. These need to be set as mount_opts e.g. `mount_opts: uid=5000,gid=5002,file_mode=0770,dir_mode=0770`


2. **NFS** `type: nfs`  (Unix-style network shares)
- Compatible with method: **autofs** and **fstab**.
- `fs_path` format: `host:/export/path`.
- Typically does not require credentials.
- Mount options may include `rw`, `nofail`, `_netdev`, etc.
- If **autofs** is used with `master_mount_point`, the `fs_path` is treated as a sub-location inside `master_mount_point`.  
  - If `master_mount_point` is not used, the base directory of `fs_path` is used as `master_mount_point`.

3. **CephFS** `type: cephfs`
- Only supports Requires: `fstab` (not `autofs`).
- Requires `fs_name` (e.g., `fast_cephfs`) and access to a Ceph configuration file.
- Credentials include `client_name`, `secret`, and `ceph_conf`.  
  - The `ceph.conf` file is copied from the Ansible control host.  
  - The keyring file is templated per client.

4. **Ceph RDB** `type: ceph_rdb`
- Only supports method: `fstab` (not `autofs`).
- Same requirements as CephFS
- Requires: 
  - `pool_name`: ceph pool name e.g. rbd.fast_rbd 
  - `image_name`: e.g. test_rdb_image
  - `fstype`: e.g. `xfs` 

NB,for method **autofs** mount points settings `mount_owner`, `mount_group`, `mount_mode` will not persist after autofs mounting. 

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Add custom_mounts
  become: true
  tags: custom_mounts
  tasks:
    - include_role:
        name: custom_mounts
        tasks_from: "{{ 'install_packages.yml' if appliances_mode == 'build' else 'main.yml' }}"
```

Example custom_mounts
----------------

```yaml
custom_mounts:
  mount_cifs:
    method: fstab
    type: cifs
    fs_path: '//192.168.124.218/install_share'
    mount_point: /mnt/install_share 
    mount_owner: "{{ analysis_user }}"
    mount_group: "{{ analysis_group }}"
    mount_mode: "0770"
    mount_opts: "mfsymlinks,vers=3.02,gid=1002,forcegid,uid=5000,forceuid,dir_mode=0770,"
    state: mounted
    dump: 0
    passno: 0
  autofs_cifs_share:
    method: autofs
    type: cifs
    fs_path: '//192.168.124.218/dev-pengu-fs'
    mount_point: /mnt/logs
    credentials:
      username: XX_PenGU
      password: "dfsf"
      domain: CYMRU
      file_path: /etc/.cifs_credentials
  nfs_fstab:
    method: fstab
    type: nfs
    fs_path: '192.168.124.203:/iso_sr_2'
    mount_point: /mnt/iso_sr_2_nfs_fstab
  autofs_nfs:
    method: autofs
    type: nfs
    fs_path: '192.168.124.203:/iso_share'
    mount_point: iso_share
    master_mount_point: /mnt/autofs_nfs
    autofs_options: "--timeout 60"
  cephfs_fstab1:
    method: fstab
    type: cephfs
    fs_name: fast_fs
    fs_path: /volumes/_nogroup/syslogs_subvol/03bb4b # path after the filesystem
    mount_point: /mnt/cephfs
    mount_opts: "_netdev"
    credentials:
      ceph_conf: ceph.conf
      client_name: fast_fs_rw
      secret: keykeykey
  ceph_rbd_data:
    method: fstab
    type: ceph_rbd
    pool_name: rbd.fast_rbd 
    image_name: test_rdb_image  
    fstype: xfs 
    mount_point: /mnt/test_rdb_image 
    mount_opts: "_netdev"
    state: mounted
    dump: 0
    passno: 0
    credentials:
      ceph_conf: ceph.conf
      client_name: fast_rbd # without .client 
      secret: dsfdfv4
```

License
-------

Apache v2

Author Information
------------------

Jonathan Jenkins jonathan.jenkins3@wales.nhs.uk
