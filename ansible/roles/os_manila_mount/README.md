Role Name
=========

Mount a CephFS share created by OpenStack Manila.

This is based on [stackhpc.os-manila-mount](https://github.com/stackhpc/ansible-role-os-manila-mount) but differs in that:
- There is no lookup mode, all required information must be provided.
- In-kernel drivers are used (no FUSE mode).
- Multiple mountpoints may be configured
- The Ceph client version is configurable.

Requirements
------------

Ansible.

Role Variables
--------------

- `os_manila_mount_access_key`: Required. The secret to use when mounting the share.
- `os_manila_mount_host`: Required. The server(s) to contact for mounting the share. If multiple use a comma-separated string with no spaces.
- `os_manila_mount_share_user`: Required. User for access key (in cephx, as requested from manila.
- `os_manila_mount_configurations`: Required. List of mappings giving per-mount options. Each mapping must contain keys:
    - `os_manila_mount_export`: The path on the server from which the share is exported.
    - `os_manila_mount_path`: The path on the server at which to mount the share.
    - `os_manila_mount_user`:  User name for which the mount point should be owned.
    - `os_manila_mount_group`: Group for which the mount point should be owned
    - `os_manila_mount_mode`: Mode for the mount point.
- `os_manila_mount_state`: Optional. Mount state as used by ansible's `mount` module. Default `mounted`.
- `os_manila_mount_ceph_version`: Optional. Ceph client version, default `octopus`.
- `os_manila_mount_ceph_repo_base`: Optional. Base of repo for Ceph client package. Default `http://mirror.centos.org/centos/$releasever/storage/x86_64/ceph-{{ os_manila_mount_ceph_version }}/`
- `os_manila_mount_ceph_repo_key`: Optional. GPG for Ceph package repo. Default `https://raw.githubusercontent.com/CentOS-Storage-SIG/centos-release-storage-common/master/RPM-GPG-KEY-CentOS-SIG-Storage`
- `os_manila_mount_ceph_conf_path`: Optional. Path for configuration files on Ceph clients. Default `/etc/ceph`.


Dependencies
------------

N/A

Example Playbook
----------------

- hosts: ceph_clients
  tasks:
  - name: Mount Openstack Manila share
    tasks:
      - include_role: os_manila_ceph
        vars:
          os_manila_mount_access_key: "{{ secrets_os_manila_mount_access_key }}"
          os_manila_mount_host: 10.60.96.12:6789,10.60.96.13:6789
          os_manila_mount_share_user: foo
          os_manila_mount_configurations:
            - os_manila_mount_export: /volumes/_nogroup/572f375c-7b29-486f-8e12-aecbd3b4cfb4
              os_manila_mount_path: /home
              os_manila_mount_user: root
              os_manila_mount_group: root
              os_manila_mount_mode: 0775

License
-------

Apache v2

Author Information
------------------

stackhpc.com
