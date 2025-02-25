# Role Name

Install and configure the [Open Ondemand](https://osc.github.io/ood-documentation/latest/) browser-based portal.

This uses the [osc.ood](https://github.com/OSC/ood-ansible) Ansible role to provide much of the functionality. Note that although this role provides some aliases for `osc.ood` role variables with new defaults, any `osc.ood` role variable may be set in inventory and will override the alias provided by this role.

## Requirements

- An OpenHPC v2.4 or later cluster (due to [this issue](https://github.com/openhpc/ohpc/issues/1346) in previous versions).
- The `openondemand` node, i.e. the node which will host the Open Ondemand server/portal must:
  - Have the slurm packages (e.g. `sinfo` etc) installed and be able to contact the Slurm controller (e.g. add this node to the `login` group).
  - Have access to any cluster shared filesystems.
- Open Ondemand's authentication maps authenticated users (e.g. via OIDC) to local users on the `openondemand` node (see `openondemand_mapping_users`). You must therefore ensure that whatever is providing users for the cluster covers the `openondemand` node, e.g. if using `basic_users` role ensure the group for this includes the `openondemand` group.

## Role Variables

### General

- `openondemand_clusters`: Required. Synonym for [osc.ood: clusters](https://github.com/OSC/ood-ansible#clusters) role variable.
- `openondemand_servername`: Required. Synonym for [osc.ood: servername](https://github.com/OSC/ood-ansible/blob/master/defaults/main/ood_portal.yml#L27) role variable. This defines what the Open Ondemand portal's Apache server uses for the [name-based virtual host](https://httpd.apache.org/docs/current/mod/core.html#servername). It should be the IP or hostname(+domain) part of the URL used to access Open Ondemand in the browser, e.g. `ondemand.mysite.org`. **NB:** If a domain or external IP is not available, specify the host's internal IP here and use ssh with a `DynamicForward` option and a SOCKS proxy to access this address. Using ssh's `LocalForward` option is not recommended as the server name will have to be `localhost` which causes some issues. Changing this value on an already deployed cluster requires a reboot of the login node for OOD app state to be correctly refreshed.

### Authentication
See the Open Ondemand [Authentication docs](https://osc.github.io/ood-documentation/latest/authentication/overview.html) for an overview of the authentication process.

- `openondemand_auth`: Required. Authentication method, either `'oidc'` or `'basic_pam'`. See relevant subsection below.
- `openondemand_mapping_users`: Required for `openondemand_auth=='oidc'`. A list of dicts defining mappings between remote authenticated usernames and local system usernames - see the Open Ondemand [user mapping docs](https://osc.github.io/ood-documentation/latest/authentication/overview/map-user.html). Each dict should have the following keys:
  - `name`: A local (existing) user account
  - `openondemand_username`: The remote authenticated username. See also `openondemand_oidc_remote_user_claim` if using OIDC authentication.

#### OIDC authentication
The following variables are active when `openondemand_auth` is `oidc`. This role uses the variables below plus a few required defaults to set the `osc.ood: ood_auth_openidc` [variable](https://github.com/OSC/ood-ansible#open-id-connect) - if the below is insufficent to correctly configure OIDC then set `ood_auth_openidc` directly.
- `openondemand_oidc_client_id`: Required. Client ID, as specified by the OIDC provider
- `openondemand_oidc_client_secret`: Required. Client secret, as specified the OIDC provider (should be vault-protected).
- `openondemand_oidc_provider_url`: Required. URL including protocol for the OIDC provider.
- `openondemand_oidc_crypto_passphrase`: Required. Random string (should be vault protected)
- `openondemand_oidc_scope`: Optional. A space-separated string giving the [OIDC scopes](https://auth0.com/docs/configure/apis/scopes/openid-connect-scopes) to request from the OIDC provider. What is available depends on the provider. Default: `openid profile preferred_username`.
- `openondemand_oidc_remote_user_claim`: Optional. A string giving the [OIDC claim](https://auth0.com/docs/configure/apis/scopes/openid-connect-scopes#standard-claims) to use as the remote user name. What is available depends on the provider and the claims made. Default: `preferred_username`.

The OIDC provider should be configured to redirect to `https://{{ openondemand_servername }}/oidc` with scopes as appropriate for `openondemand_oidc_scope`.


#### Basic/PAM authentication
This option uses HTTP Basic Authentication (i.e. browser prompt) to get a username and password. This is then checked against an existing local user using PAM. Note that HTTPS is configured by default, so the password is protected in transit, although there are [other](https://security.stackexchange.com/a/990) security concerns with Basic Authentication.

No other authentication options are required for this method.

### SSL Certificates
This role enables SSL on the Open Ondemand server, using the following self-signed certificate & key which are autogenerated by the `mod_ssl` package installed as part of the `ondemand-apache` package. Replace with your own keys if required.
- `openondemand_ssl_cert`: Optional. Default `/etc/pki/tls/certs/localhost.crt`.
- `openondemand_ssl_cert_key`: Optional. Default `/etc/pki/tls/private/localhost.key`

### Dashboard and application configuration
- `openondemand_dashboard_docs_url`: Optional. URL of docs to show under Help in dashboard. Default `(undefined)`.
- `openondemand_dashboard_links`: Optional. List of mappings defining additional links to add as menu items in the dashboard. Keys are:
    - `name`: Required. User-facing name for the link.
    - `category`: Required. Menu to add link under, either a default one (e.g. `Files`, `Jobs`, `Clusters`, `Interactive Apps`) or a new category to add.
    - `icon`: Optional. URL of icon, defaults to Open Ondemand clock icon as used in standard menus.
    - `url`: Required. URL of link.
    - `new_window`: Optional. Whether to open link in new window. Bool, default `false`.
    - `app_name`: Optional. Unique name for app appended to `/var/www/ood/apps/sys/`. Default is `name`, useful if that is not unique or not suitable as a path component.
- `openondemand_dashboard_support_url`: Optional. URL or email etc to show as support contact under Help in dashboard. Default `(undefined)`.
- `openondemand_desktop_partition`: Optional. Name of Slurm partition to use for remote desktops. Requires a corresponding group named "openondemand_desktop" and entry in openhpc_slurm_partitions.
- `openondemand_desktop_screensaver`: Optional. Whether to enable screen locking/screensaver. **NB:** Users must have passwords if this is enabled. Bool, default `false`.
- `openondemand_filesapp_paths`: List of paths (in addition to $HOME, which is always added) to include shortcuts to within the Files dashboard app.
- `openondemand_jupyter_partition`: Required. Name of Slurm partition to use for Jupyter Notebook servers. Requires a corresponding group named "openondemand_jupyter" and entry in openhpc_slurm_partitions.

### Monitoring
- `openondemand_exporter`: Optional. Install the Prometheus [ondemand_exporter](https://github.com/OSC/ondemand_exporter) on the `openondemand` node to export metrics about Open Ondemand itself. Default `true`.

### Proxying
The Open Ondemand portal can proxy other servers. Variables:

- `openondemand_host_regex`: Synomyn for the `osc.ood: host_regex` [variable](https://osc.github.io/ood-documentation/latest/app-development/interactive/setup/enable-reverse-proxy.html). A Python regex matching servernames which Open Ondemand should proxy. Enables proxying and restricts which addresses are proxied (for security). E.g. this might be:

  `'({{ openhpc_cluster_name }}-compute-\d+)|({{ groups["grafana"] | first }})'`

  to proxy:
  - All "compute" nodes, e.g. for Open Ondemand interactive apps such as remote desktop and Jupyter notebook server.
  - The Grafana server - note a link to Grafana is always added to the Open Ondemand dashboard.

  The exact pattern depends on inventory hostnames / partitions / addresses.

- `openondemand_node_proxy_directives`: Optional, default ''. Multiline string to insert into Apache directives definition for `node_uri` ([docs](https://osc.github.io/ood-documentation/master/reference/files/ood-portal-yml.html#configure-reverse-proxy)).

Note that:
- If Open Ondemand and Grafana are deployed, Grafana is automatically configured so that proxying it through Open Ondemand works.
- The `osc.ood` role variables `node_uri` and `rnode_uri` are set automatically if `openondemand_host_regex` is set.

# Dependencies

- `osc.ood` role as described above.

# Example Playbook

See `ansible/portal.yml`. Note the `main` playbook should be run on the `openondemand` node (i.e. the node to configure as hosting the Open Ondemand server/portal), and the other playbooks should be run on some subset of the `compute` group.

# License

Apache v2

# Author Information

Stackhpc Ltd.
