# sshd

Configure sshd.

## Role variables

- `sshd_password_authentication`: Optional bool. Whether to enable password login. Default `false`.
- `sshd_conf_src`: Optional string. Path to sshd configuration template. Default is in-role template.
- `sshd_conf_dest`: Optional string. Path to destination for sshd configuration file. Default is `/etc/ssh/sshd_config.d/10-ansible.conf` which overides `50-{cloud-init,redhat}` files, if present.
