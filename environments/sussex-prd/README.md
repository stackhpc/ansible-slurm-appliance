# Sussex Production Environment

# Required resources
The following resources must be manually provisioned before deployment:
- Volumes named `prd-state` and `prd-home`
- A FIP; the address must be set as the `fip` attribute for the login node in Tofu variable
`login_nodes`.
- Networks as defined in the *.tf files. **NB** The storage subnet must not have a default gateway.
- A CephFS share named "slurm-software" for shared software.

# Cluster Overview

Resources marked `*` below are **not** defined in the Tofu configuration and hence persist if the
cluster is deleted.

```
 │    tenant_net*      storage_net*
 │      │                  │
 │ ┌──┐ │                  │ ┌─────────┐
 ├─┤X*├─┤  ┌ FIP:SSH/HTTPS ├─┤nfs      │
 │ └──┘ │ ┌┴──────┐        │ └┬────────┘
 │      ├─┤login-0├────────┤  └─home-volume*
        │ └───────┘        │
        | ┌───────┐        │
        ├─┤control├────────┤
        | └┬──────┘        │
        |  └─state-volume* │
        | ┌───────┐        │
        ├─┤squid-0├────────┤
        | └───────┘        │
        | ┌───────┐        │
        ├─┤squid-1├────────┤
          └───────┘        │
                           │ ┌─────────┐
                           ├─┤compute-0│
                           │ └─────────┘
                           │ ┌─────────┐
                           ├─┤compute-1│
                           │ └─────────┘
                           .
                           .
```

- The `tenant_net` network is an OpenStack tenant network. The default gateway is
  the router interface connecting to the external network.
- The `storage_net` network is a provider network with routing to NFS/lustre.
  This has no default gateway (to avoid routing loops with dual-interfaced nodes). Outbound internet
  for compute nodes is provided via the first squid proxy. Both are used as CVMFS proxies.
- The login node has a FIP with SSH and HTTPS enabled and runs fail2ban. It also proxies
  Grafana via OOD.
- All nodes use `/etc/hosts` for cluster name resolution.
- In lieu of actual Sussex NFS/lustre access at present, the appliance is configured to provision
  an NFS server on the storage network. This will export directories from an OpenStack
  volume which persists on cluster deletion.
- User definition is templated via the `basic_users` role.
- The `/var/lib/state` directory on the control node (mounted on an Openstack volume) is
exported to the login node to allow the `persist_hostkeys` role to be used.
- The cluster uses an OFED image.
- All hosts have `/mnt/shared` mounted from the `slurm-software` CephFS share.

# Exports and Resources

- From the NFS server (`prd-nfs`): `/exports/grid-sessions/` for GridPP user session data.
- From the control node (`prd-control`): `/exports/slurm/` for Slurm user binaries (in `bin/`) and `slurm.conf` configuration (in `etc/`).

Mounting both of these on the `arc-ce` VM will require that VM to be added to the cluster's security group.

# Images

The cluster image is currently a StackHPC [Slurm Appliance release image](https://github.com/stackhpc/ansible-slurm-appliance/releases).
However a variant has been created for baremetal flavors having traits defining root disk RAID configuration. These variants are suffixed
`-raid-vN` (where `N` is a version number). Such images are currently created manually with e.g.:

    $ virt-customize -a openhpc-ofed-RL9-240621-1308-96959324 \
        --run-command 'dracut --regenerate-all -fv --mdadmconf --fstab --add=mdraid --add-driver="raid1 raid0"' \
        --edit '/etc/default/grub:s/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="rd.auto=1 /' \
        --run-command 'grub2-mkconfig -o /boot/grub2/grub.cfg --update-bls-cmdline'
    $ mv openhpc-ofed-RL9-240621-1308-96959324 openhpc-ofed-RL9-240621-1308-96959324-raid-v1

Before uploading the UUID of the root filesystem should be identified:

    $ virt-filesystems -a openhpc-ofed-RL9-240621-1308-96959324-raid-v1 --all --long --uuid -h
      Name      Type       VFS     Label MBR Size  Parent   UUID
      /dev/sda1 filesystem unknown -     -   2.0M  -        -
      /dev/sda2 filesystem vfat    EFI   -   100M  -        87CE-67FF
      /dev/sda3 filesystem xfs     BOOT  -   936M  -        d3a162d2-8620-451f-b0cd-848ad2a497a1
      /dev/sda4 filesystem xfs     rocky -   14G   -        23377f0c-c198-4759-9a12-81288e0019ae
      /dev/sda1 partition  -       -     -   2.0M  /dev/sda -
      /dev/sda2 partition  -       -     -   100M  /dev/sda -
      /dev/sda3 partition  -       -     -   1000M /dev/sda -
      /dev/sda4 partition  -       -     -   14G   /dev/sda -
      /dev/sda  device     -       -     -   15G   -        -

Here, `/dev/sda4` => `23377f0c-c198-4759-9a12-81288e0019ae`

    $ openstack image create \
        --file openhpc-ofed-RL9-240621-1308-96959324-raid-v1 \
        --disk-format qcow2 \
        --min-disk 15 \
        --property rootfs_uuid=23377f0c-c198-4759-9a12-81288e0019ae \
        openhpc-ofed-RL9-240621-1308-96959324-raid-v1
