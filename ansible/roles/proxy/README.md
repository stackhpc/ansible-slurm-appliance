# proxy

Define http/s proxy configuration.

## Role variables

- `proxy_http_proxy`: Required. Address of http proxy. E.g. "http://10.1.0.28:3128" for a Squid proxy on default port.
- `proxy_https_proxy`: Optional. Address of https proxy. Default is `{{ proxy_http_proxy }}`.
- `proxy_no_proxy`: Optional. Comma-separated list of addresses not to proxy. Default is to concatenate `inventory_hostname` (for hostnames) and `ansible_host` (for host IPs) for all Ansible hosts.
- `proxy_dnf`: Optional bool. Whether to configure yum/dnf proxying through `proxy_http_proxy`. Default `true`.
- `proxy_systemd`: Optional bool. Whether to give processes started by systemd the above http, https and no_proxy configuration. **NB** Running services will need restarting if this is changed. Default `true`.
