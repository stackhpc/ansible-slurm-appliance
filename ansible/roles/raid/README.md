# raid

Configure an image to support software raid (via [mdadm](https://github.com/md-raid-utilities/mdadm)).

RockyLinux genericcloud images already have the necessary `mdraid` dracut
module installed, as well as kernel modules for `raid0`, `raikd1`, `raid10` and
`raid456` [^1]. This covers all raid modes [supported by Ironic](https://docs.openstack.org/ironic/latest/admin/raid.html#software-raid)
hence this role does not support extending this.

This role changes the command line for the current kernel. It does not reboot
the instance so generally is only useful during image builds.

[^1]: As shown by `lsinitrd /boot/initramfs-$(uname -r).img | grep raid`
