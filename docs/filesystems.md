# Overview

The Slurm appliance supports mounting shared filesystems using [CephFS](https://docs.ceph.com/en/latest/cephfs/) via [OpenStack Manila](https://wiki.openstack.org/wiki/Manila). These docs explain:

- How to create the shares in OpenStack Manilla

- How to configure the Slurm Appliance to mount these Manila shares.

- How to disable use Manila shares for a shared home directory.

## Creating shares in OpenStack

The Slurm appliance requires that the Manila shares already exist on the system. Follow the instructions below to do this.

If this is the first time Manila is being used on the system, a CephFS share type will need to be created. You will need admin credentials to do this.

  ```bash
  openstack share type create cephfs-type false --extra-specs storage_protocol=CEPHFS, vendor_name=Ceph
  ```

Once this exists, create a share using credentials for the Slurm project. An access rule also needs to be created, where the “access_to” argument (`openstack share access create <share> <access_type> <access_to>`) is a user that will be created in Ceph. This needs to be globally unique in Ceph, so needs to be different for each OpenStack project.

  ```bash
  openstack share create CephFS 300 --description 'Scratch dir for Slurm prod' --name slurm-production-scratch --share-type cephfs-type --wait
  openstack share access create slurm-production-scratch cephx slurm-production
  ```

## Configuring the Slurm Appliance for Manila

To mount shares onto hosts in a group, add the to the `manila` group.

  ```ini
  [manila:children]
  login
  compute
  ```

Set the version of Ceph which is running on the system.

  ```yaml
  os_manila_mount_ceph_version: "18.2.4"
  ```

Define the list of shares to be mounted, and the paths to mount them to. See the [stackhpc.os-manila-mount role](https://github.com/stackhpc/ansible-role-os-manila-mount) for further configuration options.

  ```yaml
  os_manila_mount_shares:
    - share_name: slurm-production-scratch
      mount_path: /scratch
  ```

### Shared home directory

By default, the Slurm appliance will spin up a local NFS server and mount the home directories to it. When using Manila + CephFS for the home directory instead, this will need to be disabled.

  ```yaml
  nfs_configurations: []
  ```

The basic_users home directory will need to be updated to point to this new shared directory.

  ```yaml
  basic_users_homedir_server: "{{ groups['login'] | first }}" # if not mounting /home on control node
  basic_users_homedir_server_path: /home
  ```

Set the Tofu variable `home_volume_size = 0` to stop Tofu from creating a new home volume. NB: If the control node has already been deployed, re-running Tofu will delete the home volume and delete/recreate the control node.

Finally, add the home directory to the list of shares (the share should be created already in OpenStack).

  ```yaml
  os_manila_mount_shares:
    - share_name: slurm-production-scratch
      mount_path: /scratch
    - share_name: slurm-production-home
      mount_path: /home
  ```
