# Overview

The Slurm appliance supports mounting shared filesystems using [CephFS](https://docs.ceph.com/en/latest/cephfs/) via [OpenStack Manila](https://docs.openstack.org/manila/latest/). This section explains:

- How to create the shares in OpenStack Manila.

- How to configure the Slurm Appliance to mount these Manila shares.

- How to switch to a Manila share for a shared home directory.

## Creating shares in OpenStack

The Slurm appliance requires that the Manila shares already exist on the system. Follow the instructions below to do this.

If this is the first time Manila is being used on the system, a CephFS share type will need to be created. You will need admin credentials to do this.

  ```bash
  openstack share type create cephfs-type false --extra-specs storage_protocol=CEPHFS vendor_name=Ceph
  ```

Once this exists, create a share using credentials for the Slurm project. An access rule also needs to be created, where the `access_to` argument (`openstack share access create <share> <access_type> <access_to>`) is a user that will be created in Ceph. This needs to be globally unique in Ceph, so needs to be different for each OpenStack project. Ideally, this share should include your environment name. In this example, the name is "production".

  ```bash
  openstack share create CephFS 300 --description 'Scratch dir for Slurm prod' --name slurm-production-scratch --share-type cephfs-type --wait
  openstack share access create slurm-production-scratch cephx slurm-production
  ```

## Configuring the Slurm Appliance for Manila

To mount shares onto hosts in a group, add them to the `manila` group.

  ```ini
  # environments/site/inventory/groups:
  [manila:children]:
  login
  compute
  ```

If you are running a different version of Ceph from the defaults in the i[os-manila-mount role](https://github.com/stackhpc/ansible-role-os-manila-mount/blob/master/defaults/main.yml), you will need to update the package version by setting the following.

  ```yaml
  # environments/site/inventory/group_vars/manila.yml:
  os_manila_mount_ceph_version: "18.2.4"
  ```

This will need to be included in the `builder` group to be installed in the host image.

  ```ini
  # environments/site/inventory/groups:
  [manila:children]:
  login
  compute
  builder
  ```

Define the list of shares to be mounted, and the paths to mount them to. The example below parameterises the share name using the environment name. See the [stackhpc.os-manila-mount role](https://github.com/stackhpc/ansible-role-os-manila-mount) for further configuration options.

  ```yaml
  # environments/site/inventory/group_vars/manila.yml:
  os_manila_mount_shares:
    - share_name: "slurm-{{ appliances_environment_name }}-scratch"
      mount_path: /scratch
  ```

### Shared home directory

By default, the Slurm appliance configures the control node as an NFS server and exports a directory which is mounted on the other cluster nodes as `/home`. When using Manila + CephFS for the home directory instead, this will need to be disabled. To do this, set the tf var `home_volume_provisioning` to `None`. 

Some `basic_users_homedir_*` parameters need overriding as the provided defaults are only satisfactory for the default root-squashed NFS share:

  ```yaml
  # environments/site/inventory/group_vars/all/basic_users.yml:
  basic_users_homedir_server: "{{ groups['login'] | first }}" # if not mounting /home on control node
  basic_users_homedir_server_path: /home
  ```

Finally, add the home directory to the list of shares (the share should be already created in OpenStack).

  ```yaml
  # environments/site/inventory/group_vars/all/manila.yml:
  os_manila_mount_shares:
    - share_name: "slurm-{{ appliances_environment_name }}-scratch"
      mount_path: /scratch
    - share_name: "slurm-{{ appliances_environment_name }}-home"
      mount_path: /home
  ```
