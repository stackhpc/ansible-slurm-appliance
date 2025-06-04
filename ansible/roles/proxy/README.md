# proxy

Define http/s proxy configuration.

## Role variables

- `proxy_http_proxy`: Required. Address of http proxy. E.g. "http://10.1.0.28:3128" for a Squid proxy on default port.
- `proxy_https_proxy`: Optional. Address of https proxy. Default is `{{ proxy_http_proxy }}`.
- `proxy_no_proxy_extra`: Optional. List of additional addresses not to proxy. Will be combined with default list which includes `inventory_hostname` (for hostnames) and `ansible_host` (for host IPs) for all Ansible hosts.
- `proxy_plays_only`: Optional bool. Whether to configure proxying only for Ansible plays (via the [environment](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_environment.html) keyword). Default `false` which means proxy configuration is written to the host and available to all users. If `true` this role must be run in the playbook for proxying to be available as it sets host facts.
- `proxy_dnf`: Optional bool. Whether to configure yum/dnf proxying through `proxy_http_proxy`. Default `true`  unless `proxy_plays_only` is `true`.
- `proxy_systemd`: Optional bool. Whether to give processes started by systemd the above http, https and no_proxy configuration. **NB** Running services will need restarting if this is changed. Default `true` unless `proxy_plays_only` is `true`.
