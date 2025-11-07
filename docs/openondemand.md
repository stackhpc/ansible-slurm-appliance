# Overview

The appliance can deploy the Open OnDemand portal. This page describes how to enable this and the default appliance configuration/behaviour. Note that detailed configuration documentation is provided by:

- The readme for the included `openondemand` role in this repository - [ansible/roles/openondemand/README.md](../ansible/roles/openondemand/README.md).
- The readme and default variables for the underlying "official" role which the above wraps - [Open OnDemand Ansible Role](https://github.com/OSC/ood-ansible)
- The documentation for Open OnDemand [itself](https://osc.github.io/ood-documentation/latest/index.html)

This appliance can deploy and configure:

- The Open OnDemand server itself (usually on a single login node).
- User authentication using one of:
  - An external OIDC provider.
  - HTTP basic authentication and PAM.
- Virtual desktops on compute nodes.
- Jupyter nodebook servers on compute nodes.
- Proxying of Grafana (usually deployed on the control node) via the Open OnDemand portal.
- Links to additional filesystems and pages from the Open OnDemand Dashboard.
- A Prometheus exporter for the Open OnDemand server and related Grafana dashboard

For examples of all of the above see the `smslabs-example` environment in this repository.

## Enabling Open OnDemand

To enable the Open OnDemand server, add single host to the `openondemand` inventory group. Generally, this should be a node in the `login` group, as Open OnDemand must be able to access Slurm commands.

To enable compute nodes for virtual desktops, Jupyter notebooks, RStudio, Visual Studio Code, or MATLAB (accessed through the Open OnDemand portal), add nodes/groups to the `openondemand_desktop`, `openondemand_jupyter`, `openondemand_rstudio`, `openondemand_codeserver`, and `openondemand_matlab` inventory groups respectively. These may be all or a subset of the `compute` group.

The above functionality is configured by running the `ansible/portal.yml` playbook. This is automatically run as part of `ansible/site.yml`.

## MATLAB

_NB_ Due to licensing, the MATLAB batch connect app requires a MATLAB intallation to be present on the relevant compute nodes. The MATLAB app is therefore disabled by default, and must be enabled by setting `openondemand_matlab_partition` in e.g. `environments/site/inventory/group_vars/all/openondemand.yml` to the name of the partition where MATLAB is available.

An Lmod modulefile also needs to be available on compute nodes - this is not provided by the appliance. See e.g.`roles/openondemand/tasks/rstudio_compute.yml` for an example. The modulefile must be named `matlab/$MATLAB_VERSION`, where the version matches thes `openondemand_matlab_version` variable. This variable is set to empty in the role default so must be defined in `environments/site/inventory/group_vars/all/openondemand.yml`.

As MATLAB requires a remote desktop, the TurboVNC and Xfce Desktop packages and configuration from the "openondemand_desktop" app will be automatically applied to nodes where the MATLAB app is enabled.

## Default configuration

See the [ansible/roles/openondemand/README.md](../ansible/roles/openondemand/README.md) for more details on the variables described below.

The following variables have been given default values to allow Open OnDemand to work in a newly created environment without additional configuration, but generally should be overridden in `environments/site/inventory/group_vars/all/` with site-specific values:

- `openondemand_servername` - this must be defined for both `openondemand` and
  `grafana` hosts (when Grafana is enabled). The default is `ansible_host` (i.e.
  the IP address) of the first host in the `openondemand` group. For production
  environments this should probably be a DNS name.
- `openondemand_ssl_cert` and `openondemand_ssl_cert_key` - by default a
  self-signed certificate is generated, which should probably be replaced for
  production environments.
- `openondemand_auth` and any corresponding options. Defaults to `basic_pam`.
- `openondemand_desktop_partition`, `openondemand_jupyter_partition`, `openondemand_rstudio_partition`, and `openondemand_codeserver_partition` if the corresponding inventory groups are defined. Defaults to the first compute group defined in the `compute` OpenTofu variable in `environments/$ENV/tofu`. Note `openondemand_matlab_partition` is not set due to the additional requirements discussed above.

It is also recommended to set:

- `openondemand_dashboard_support_url`
- `openondemand_dashboard_docs_url`

If shared filesystems other than `$HOME` are available, add paths to `openondemand_filesapp_paths`.

The appliance automatically configures Open OnDemand to proxy Grafana and adds a link to it on the Open OnDemand dashboard. This means no external IP (or SSH proxying etc) is required to access Grafana (which by default is deployed on the control node). To allow users to authenticate to Grafana, the simplest option is to enable anonymous (View-only) login by setting `grafana_auth_anonymous` (see [environments/common/inventory/group_vars/all/grafana.yml](../environments/common/inventory/group_vars/all/grafana.yml)[^1]).

[^1]: Note that if `openondemand_auth` is `basic_pam` and anonymous Grafana login is enabled, the appliance will (by default) configure Open OnDemand's Apache server to remove the Authorisation header from proxying of all `node/` addresses. This is done as otherwise Grafana tries to use this header to authenticate, which fails with the default configuration where only the admin Grafana user `grafana` is created. Note that the removal of this header in this configuration means it cannot be used to authenticate proxied interactive applications - however the appliance-deployed remote desktop and Jupyter Notebook server applications use other authentication methods. An alternative if using `basic_pam` is not to enable anonymous Grafana login and to create Grafana users matching the local users (e.g. in `environments/<env>/hooks/post.yml`).

## Image Build
By default, most ondemand apps are installed in image builds when the build includes the inventory group `openondemand` (which is the default for "fatimage" builds). The apps installed are
defined by the `openondemand_<app>_partition` variables in `environments/common/inventory/group_vars/all/builder/defaults.yml`. Note that in this case the values are not strings and are instead
simply truthy, i.e. they do not describe cluster partition groups but just whether those apps will be installed in the image or not.

For e.g. site-specific image builds where different app installs are required, due to precedence rules these must overriden in a `builder`-groupvars file e.g. `environments/site/inventory/group_vars/all/builder/defaults.yml`.

## Access

By default the appliance authenticates against OOD with basic auth through PAM. When creating a new environment, a new user with username `demo_user` will be created.
Its password is found under `vault_openondemand_default_user` in the appliance secrets store in `environments/{ENV}/inventory/group_vars/all/secrets.yml`.
Other users can be defined by overriding the `basic_users_users` variable in your environment (templated into `environments/{ENV}/inventory/group_vars/all/basic_users.yml` by default).
