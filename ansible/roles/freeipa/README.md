
# freeipa

Support FreeIPA in the appliance. In production use it is expected the FreeIPA server(s) will be external to the cluster, implying that hosts and users are managed outside the appliance. However for testing and development the role can also deploy a FreeIPA server, add hosts to it and manage users on that host.

# FreeIPA Client

## Usage
- Add hosts to the `freeipa_client` group and run (at a minimum) the `ansible/iam.yml` playbook.
- Host names must match the domain name. By default (using the skeleton Terraform) hostnames are of the form `nodename.cluster_name.tld` where `cluster_name` and `tld` are Terraform variables.
- Hosts discover the FreeIPA server from DNS records. If using an external FreeIPA server and the default nameservers do not have these records, the external FreeIPA server could be used as the nameserver directly by setting `freeipa_setup_dns: true` and `freeipa_server_ip`.
- For production use (i.e. with an external FreeIPA server), a random one-time password (OTP) should be generated when adding hosts to FreeIPA (e.g. using `ipa host-add --random ...`). This password should be set as a hostvar `freeipa_host_password`. Initial host enrolment will use this OTP to enrole the host. After this it becomes irrelevant so it does not need to be committed to git. This approach means the appliance does not require the FreeIPA administrator password.
- The `control` host must define `appliances_state_dir` (on persistent storage). This is used to backup keytabs to allow FreeIPA clients to be renroled after e.g. reimaging. Note that:
  - This is implemented when using the skeleton Terraform; on the control node `appliances_state_dir` defaults to `/var/lib/state` which is mounted from a volume.
  - Nodes are not re-enroled by a Slurm-driven reimage (see the [rebuild role's readme](../../collections/ansible_collections/stackhpc/slurm_openstack_tools/roles/rebuild/README.md)) as that does not run this role.
  - If both a backed-up keytab and `freeipa_host_password` exist, the former is used.


## Role Variables for Clients

- `freeipa_host_password`. Required for initial enrolment only, FreeIPA host password as described above.
- `freeipa_setup_dns`: Optional, whether to use the FreeIPA server as the client's nameserver. Defaults to `true` when `freeipa_server` contains a host, otherwise `false`.
- `freeipa_server_ip`: IP address of FreeIPA server. Only required for client if `freeipa_setup_dns` is true. Default in common environment is `ansible_host` of `freeipa_server` host.

See also use of `appliances_state_dir` on the control node as described above.

# FreeIPA Server
As noted above this is only intended for development and testing.

## Usage
- Add a single host to the `freeipa_server` group.
- As well as configuring the FreeIPA server, the role will also:
  - Automatically configure the FreeIPA server as the first nameserver for `freeipa_client` hosts.
  - Add ansible hosts in the group `freeipa_client` as FreeIPA hosts.
  - Optionally control users in FreeIPA - see `freeipa_users` below.
- The `server.yml` playbook should be run on the `freeipa_server` host and the `addhost.yml` task file on the `freeipa_client` hosts (but only when a host is in `freeipa_server`). See `bootstrap.yml` for examples.

## Role Variables for Server

These role variables are only required when using `freeipa_server`:

- `freeipa_realm`: Optional, name of realm. Default is `{{ openhpc_cluster_name | upper }}.INVALID`
- `freeipa_domain`: Optional, name of domain. Default is lowercased `freeipa_realm`.
- `freeipa_ds_password`: Optional, password to be used by the Directory Server for the Directory Manager user (`ipa-server-install --ds-password`). Default is generated in `environments/<environment>/inventory/group_vars/all/secrets.yml`
- `freeipa_admin_password`: Optional, password for the IPA `admin` user. Default is generated as for `freeipa_ds_password`.
- `freeipa_server_ip`: Optional, IP address of freeipa_server host. Default is `ansible_host` of the `freeipa_server` host.
- `freeipa_setup_dns`: Optional bool, whether to configure the FreeIPA server as an integrated DNS server and define a zone and records. NB: This also controls whether `freeipa_client` hosts use the `freeipa_server` host for name resolution. Default `true` when `freeipa_server` contains a host.
- `freeipa_client_ip`: Optional, IP address of FreeIPA client. Default is `ansible_host`.
- `freeipa_users`: A list of dicts as per parameters for [community.general.ipa_user](https://docs.ansible.com/ansible/latest/collections/community/general/ipa_user_module.html). Note that:
  - `name`, `givenname` (firstname) and `sn` (surname) are required.
  - `ipa_pass` and `ipa_user` are automatically supplied.
  - If `password` is set, the value should *not* be a hash (unlike `ansible.builtin.user` as used by the `basic_users` role), and it must be changed on first login. `krbpasswordexpiration` does not appear to be able to override this.
