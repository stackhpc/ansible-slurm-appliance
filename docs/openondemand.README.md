# Overview

The appliance can deploy the Open Ondemand portal. This page describes how to enable this and the default appliance configuration/behaviour. Note that detailed configuration documentation is provided by:

- The README for the included `openondemand` role in this repo - [ansible/roles/openondemand/README.md](../ansible/roles/openondemand/README.md).
- The README and default variables for the underlying "official" role which the above wraps - [Open OnDemand Ansible Role](https://github.com/OSC/ood-ansible)
- The documentation for Open Ondemand [itself](https://osc.github.io/ood-documentation/latest/index.html)

This appliance can deploy and configure:
- The Open Ondemand server itself (usually on a single login node).
- User authentication using one of:
    - An external OIDC provider.
    - HTTP basic authenication and PAM.
- Virtual desktops on compute nodes.
- Jupyter nodebook servers on compute nodes.
- Proxying of Grafana (usually deployed on the control node) via the Open Ondemand portal.
- Links to additional filesystems and pages from the Open Ondemand Dashboard.
- A Prometheus exporter for the Open Ondemand server and related Grafana dashboard

For examples of all of the above see the `smslabs-example` environment in this repo.

# Enabling Open Ondemand
To enable the Open Ondemand server, add single host to the `openondemand` inventory group. Generally, this should be a node in the `login` group, as Open Ondemand must be able to access Slurm commands.

To enable compute nodes for virtual desktops or Jupyter notebook servers (accessed through the Open Ondemand portal), add nodes/groups to the `openondemand_desktop` and `openondemand_jupyter` inventory groups respectively. These may be all or a subset of the `compute` group.

The above functionality is configured by running the `ansible/portal.yml` playbook. This is automatically run as part of `ansible/site.yml`.

# Default configuration

See the [ansible/roles/openondemand/README.md](../ansible/roles/openondemand/README.md) for more details on the variables described below.

At minimum the following must be defined:
- `openondemand_servername` - this must be defined for both `openondemand` and `grafana` hosts (when Grafana is enabled). It is suggested to place it groupvars for `all`.
- `openondemand_auth` and any corresponding options.
- `openondemand_desktop_partition` and `openondemand_jupyter_partition` if the corresponding inventory groups are defined.
- `openondemand_host_regex` if `openondemand_desktop` or `openondemand_jupyter` inventory groups are defined and/or proxying Grafana via Open Ondemand is required.

It is also recommended to set:
- `openondemand_dashboard_support_url`
- `openondemand_dashboard_docs_url`

If shared filesystems other than `$HOME` are available, add paths to `openondemand_filesapp_paths`.

The appliance automatically configures Open Ondemand to proxy Grafana and adds a link to it on the Open Ondemand dashboard. This means no external IP (or SSH proxying etc) is required to access Grafana (which by default is deployed on the control node). To allow users to authenticate to Grafana, the simplest option is to enable anonymous (View-only) login by setting `grafana_auth_anonymous` (see [environments/common/inventory/group_vars/all/grafana.yml](../environments/common/inventory/group_vars/all/grafana.yml)[^1]).

[^1]: Note that if `openondemand_auth` is `basic_pam` and anonymous Grafana login is enabled, the appliance will (by default) configure Open Ondemand's Apache server to remove the Authorisation header from proxying of all `node/` addresses. This is done as otherwise Grafana tries to use this header to authenticate, which fails with the default configuration where only the admin Grafana user `grafana` is created. Note that the removal of this header in this configuration means it cannot be used to authenticate proxied interactive applications - however the appliance-deployed remote desktop and Jupyter Notebook server applications use other authentication methods. An alternative if using `basic_pam` is not to enable anonymous Grafana login and to create Grafana users matching the local users (e.g. in `environments/<env>/hooks/post.yml`).
