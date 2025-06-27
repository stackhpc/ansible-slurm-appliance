# proxy

Define http/s proxy configuration.

## Role variables

- `proxy_http_proxy`: Required str. Address of http proxy, e.g. `'http://squid.mysite.org:3128`'.
  **NB:** If the `squid` group is enabled, this defaults to the address of the
  first host in that group and the configured port. See `environments/common/inventory/group_vars/all/proxy.yml`
  for other convenience variables to configure this.
- `proxy_https_proxy`: Optional string. Address of https proxy. Default is `{{ proxy_http_proxy }}`.
- `proxy_no_proxy_extra`: Optional list. Additional addresses not to proxy. Will
  be combined with default list which includes `inventory_hostname` (for hostnames)
  and `ansible_host` (for host IPs) for all Ansible hosts.
- `proxy_dnf`: Optional bool. Whether to configure yum/dnf proxying through `proxy_http_proxy`.
  Default `true`.
- `proxy_systemd`: Optional bool. Whether to give processes started by systemd
  the above http, https and no_proxy configuration. **NB** Running services will
  need restarting if this is changed. Default `true`.
