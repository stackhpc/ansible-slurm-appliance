# spectrum_scale

A wrapper around the [ibm.spectrum_scale](https://github.com/stackhpc/ibm-spectrum-scale-install-infra)
collection which:
- Installs from an s3 bucket
- Uses automatic backup/restore to enable reimaging the cluster.

It has task files `install.yml` and `configure.yml` intended to be used during
image build and cluster configuration respectively.

## Role variables
- `spectrum_scale_version`: Required: Version of Spectrum Scale, e.g. `5.1.6.1`.
- `spectrum_scale_installer_s3path`: Required. S3 path to installer, e.g.
  `s3://spectrum_scale/Spectrum_Scale_Erasure_Code-5.1.6.1-x86_64-Linux-install`
- `spectrum_scale_installer_md5sum`: Required. md5sum of installer
- `spectrum_scale_s3cfg`: Required. A multiline string providing the contents
  of an s3cfg file with access to the above path.
- `spectrum_scale_backup_path`: Optional. Path for backup. Default uses persistent state directory `appliances_state_dir`.
- `spectrum_scale_backup_host`: Optional. Host with `spectrum_scale_backup_path` to to use for backup/restore. Defaults to control node.
- `spectrum_scale_binary_path`: Optional. Path to installed spectrum scale binaries. Default `/usr/lpp/mmfs/bin`.

Note this role sets some variables via `vars/main.yml`, which are used to
override the variables seen by the wrapped IBM role.

## Notes
**NB:** The IBM roles cannot manage all changes to scale_remotemount_filesystem_name once filesystems have been mounted.
To reset the configuration, run the following as root on any spectrum_scale node before re-running ansible:

```shell
# Unmount all remote GPFS filesystems:
[root@compute-0 cloud-user]# /usr/lpp/mmfs/bin/mmumount all_remote -N all
# Delete all local information about the remote filesystems:
[root@compute-0 cloud-user]# /usr/lpp/mmfs/bin/mmremotefs delete all
```
