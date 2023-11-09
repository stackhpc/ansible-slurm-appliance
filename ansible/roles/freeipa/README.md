
# freeipa

Support FreeIPA in the appliance. In production use it is expected the FreeIPA server(s) will be external to the cluster, implying that hosts and users are managed outside the appliance. However for testing and development the role can also deploy an "in-appliance" FreeIPA server, add hosts to it and manage users in FreeIPA.

# FreeIPA Client

## Usage
- Add hosts to the `freeipa_client` group and run (at a minimum) the `ansible/iam.yml` playbook.
- Host names must match the domain name. By default (using the skeleton Terraform) hostnames are of the form `nodename.cluster_name.cluster_domain_suffix` where `cluster_name` and `cluster_domain_suffix` are Terraform variables.
- Hosts discover the FreeIPA server FQDN (and their own domain) from DNS records. If DNS servers are not set this is not set from DHCP, then use the `resolv_conf` role to configure this. For example when using the in-appliance FreeIPA development server:
  
  ```ini
  # environments/<env>/groups
  ...
  [resolv_conf:children]
  freeipa_client
  ...
  ```

  ```yaml
  # environments/<env>/inventory/group_vars/all/resolv_conf.yml
  resolv_conf_nameservers:
  - "{{ hostvars[groups['freeipa_server'] | first].ansible_host }}"
  ```


- For production use with an external FreeIPA server, a random one-time password (OTP) must be generated when adding hosts to FreeIPA (e.g. using `ipa host-add --random ...`). This password should be set as a hostvar `freeipa_host_password`. Initial host enrolment will use this OTP to enrol the host. After this it becomes irrelevant so it does not need to be committed to git. This approach means the appliance does not require the FreeIPA administrator password.
- For development use with the in-appliance FreeIPA server, `freeipa_host_password` will be automatically generated in memory.
- The `control` host must define `appliances_state_dir` (on persistent storage). This is used to back-up keytabs to allow FreeIPA clients to automatically re-enrol after e.g. reimaging. Note that:
  - This is implemented when using the skeleton Terraform; on the control node `appliances_state_dir` defaults to `/var/lib/state` which is mounted from a volume.
  - Nodes are not re-enroled by a [Slurm-driven reimage](../../collections/ansible_collections/stackhpc/slurm_openstack_tools/roles/rebuild/README.md) (as that does not run this role).
  - If both a backed-up keytab and `freeipa_host_password` exist, the former is used.


## Role Variables for Clients

- `freeipa_host_password`. Required for initial enrolment only, FreeIPA host password as described above.
- `freeipa_setup_dns`: Optional, whether to use the FreeIPA server as the client's nameserver. Defaults to `true` when `freeipa_server` contains a host, otherwise `false`.

See also use of `appliances_state_dir` on the control node as described above.

# FreeIPA Server
As noted above this is only intended for development and testing. Note it cannot be run on the `openondemand` node as no other virtual servers must be defined in the Apache configuration.

## Usage
- Add a single host to the `freeipa_server` group and run (at a minimum) the `ansible/bootstrap.yml` and `ansible/iam.yml` playbooks.
- As well as configuring the FreeIPA server, the role will also:
  - Add ansible hosts in the group `freeipa_client` as FreeIPA hosts.
  - Optionally control users in FreeIPA - see `freeipa_users` below.

The FreeIPA GUI will be available on `https://<freeipa_server_ip>/ipa/ui`.

## Role Variables for Server

These role variables are only required when using `freeipa_server`:

- `freeipa_realm`: Optional, name of realm. Default is `{{ openhpc_cluster_name | upper }}.INVALID`
- `freeipa_domain`: Optional, name of domain. Default is lowercased `freeipa_realm`.
- `freeipa_ds_password`: Optional, password to be used by the Directory Server for the Directory Manager user (`ipa-server-install --ds-password`). Default is generated in `environments/<environment>/inventory/group_vars/all/secrets.yml`
- `freeipa_admin_password`: Optional, password for the IPA `admin` user. Default is generated as for `freeipa_ds_password`.
- `freeipa_server_ip`: Optional, IP address of freeipa_server host. Default is `ansible_host` of the `freeipa_server` host. Default `false`. 
- `freeipa_setup_dns`: Optional bool, whether to configure the FreeIPA server as an integrated DNS server and define a zone and records. NB: This also controls whether `freeipa_client` hosts use the `freeipa_server` host for name resolution. Default `true` when `freeipa_server` contains a host.
- `freeipa_client_ip`: Optional, IP address of FreeIPA client. Default is `ansible_host`.
- `freeipa_users`: A list of dicts defining users to add, with keys/values as for [community.general.ipa_user](https://docs.ansible.com/ansible/latest/collections/community/general/ipa_user_module.html): Note that:
  - `name`, `givenname` (firstname) and `sn` (surname) are required.
  - `ipa_host`, `ipa_port`, `ipa_prot`, `ipa_user`, `validate_certs` are automatically provided and cannot be overridden.
  - If `password` is set, the value should *not* be a hash (unlike `ansible.builtin.user` as used by the `basic_users` role), and it must be changed on first login. `krbpasswordexpiration` does not appear to be able to override this.
