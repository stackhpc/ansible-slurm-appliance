# sssd

Install and configure [sssd](https://sssd.io/docs/introduction.html).


## Role variables

The only required configuration is to create a [sssd.conf](https://www.mankier.com/5/sssd.conf) template at the location specified by `sssd_conf_src`.

- `sssd_packages`: Optional list. Packages to install.
- `sssd_ldap_install`: Optional bool. Whether to install packages enabling SSSD to authenticate against LDAP. Default `false`.
- `sssd_ldap_packages`: Optional list. Packages to install when using `sssd_ldap_install`.
- `sssd_conf_src`: Optional string. Path to `sssd.conf` template. Default (which must be created) is `{{ appliances_environment_root }}/files/sssd.conf.j2`.
- `sssd_conf_dest`: Optional string. Path to destination for `sssd.conf`. Default `/etc/sssd/sssd.conf`.
- `sssd_started`: Optional bool. Whether `sssd` service should be started.
- `sssd_enabled`: Optional bool. Whether `sssd` service should be enabled.
