block_devices
=============

Manage filesystems on block devices (such as OpenStack volumes), including creating partitions, creating filesystems and mounting filesystems.

This is a convenience wrapper around the ansible modules:
- community.general.parted
- community.general.filesystem
- ansible.buildin.file
- ansible.posix.mount

To avoid issues with device names changing after e.g. reboots, devices are identified by serial number and mounted by filesystem UUID.

**NB:** This role is ignored[^1] during Packer builds as block devices will not be attached to the Packer build VMs. This role is therefore deprecated and it is suggested that `cloud-init` is used instead. See e.g. `environments/skeleton/{{cookiecutter.environment}}/terraform/control.userdata.tpl`.

[^1]: See `environments/common/inventory/group_vars/builder/defaults.yml`

Requirements
------------

N/A.

Role Variables
--------------

- `block_devices_partition_state`: Optional. Partition state, 'present' or 'absent' (as for parted) or 'skip'. Defaults to 'present'.
- `block_devices_serial`: Required. Serial number of block device. For an OpenStack volume this is the volume ID.
- `block_devices_number`: Required. Partition number, e.g 1 for "/dev/sda1". See `community.general.parted:number`.
- `block_devices_fstype`: Required. Filesystem type, e.g.'ext4'. See `community.general.filesystem:fstype`
- `block_devices_resizefs`: Optional. Grow filesystem into block device space, 'yes' or 'no' (default). See `community.general.filesystem:resizefs` for applicable fileysystem types.
- `block_devices_filesystem_state`: Optional. Whether filesystem should be 'present' (default) or 'absent', or 'skip'.
- `block_devices_path`: Required. Path to mount point, e.g. '/mnt/files'.
- `block_devices_mount_state`: Optional. Mount state, 'absent', 'mounted' (default), 'present', 'unmounted' or 'remounted' - see `ansible.posix.mount:state`
- `block_devices_owner`: Optional. Name of owner for mounted directory (as for `ansible.buildin.file:owner`), or omitted.
- `block_devices_group`: Optional. Name of group for mounted directory (as for `ansible.buildin.file.group`), or omitted.

Multiple NFS client/server configurations may be provided by defining `block_devices_configurations`. This should be a list of mappings with keys/values are as per the variables above without the `block_devices_` prefix. Omitted keys/values are filled from the corresponding variable.

Dependencies
------------

See top of page.

Example Playbook
----------------

```yaml
- hosts: servers
  become: true
  tasks:
  - include_role:
    name: block_devices
```

The example variables below create an `ext4` partition on `/dev/sdb1` and mount it as `/mnt/files` with the default owner/group:

```yaml
block_devices_serial: a1076455-da55-4e0c-bac8-ccc4698cff97
block_devices_number: 1
block_devices_fstype: ext4
block_devices_path: /mnt/files
```

This does the same:

```yaml
block_devices_configurations:
  - serial: a1076455-da55-4e0c-bac8-ccc4698cff97
    number: 1
    fstype: ext4
    path: /mnt/files
```

License
-------

Apache V2

Author Information
------------------

stackhpc.com
