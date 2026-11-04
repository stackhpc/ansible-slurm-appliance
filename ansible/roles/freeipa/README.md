# freeipa

Support enroling nodes with FreeIPA in the appliance. The FreeIPA server(s) are
external to the appliance and hosts and users must pre-exist.

## Usage

- Ensure client node hostnames are fully qualified and match the domain name.
  By default (using site/tofu/ templates) hostnames are of the form
  `nodename.cluster_name.cluster_domain_suffix` where `cluster_name` and
  `cluster_domain_suffix` are OpenTofu variables.
- Define client nodes as hosts in FreeIPA. This is outside the scope of this
  document but some hints are provided below.
- Add client hosts to the `freeipa_client` group and set role variables as
  described below.
- Run (at a minimum) the `ansible/iam.yml` playbook.

The method used to manage host enrolment depends on `freeipa_enrol_method`:

- `otp`: Default. Hosts are initially enroled using a random one-time password
  (OTP). On enrolment the keytabs are stored in the control node's `appliances_state_dir`
  and used to re-enrol after rebuild/reimage of nodes.
- `pkinit`: Hosts are enroled and re-enroled using [PKINIT](https://www.freeipa.org/page/V4/Kerberos_PKINIT),
  i.e. host certificates and keys stored (Ansible Vault-encrypted) in the
  appliance repository.

Neither method requires the appliance to have access to the FreeIPA administrator
password.

### OTP enrolment mode

In this mode hosts discover the FreeIPA server FQDN (and their own domain) from
DNS records. If DNS servers are not provided via DHCP, use the `resolv_conf` role
to configure this, e.g.:

```ini
# environments/site/groups
...
[resolv_conf:children]
freeipa_client
...
```

```yaml
# environments/site/inventory/group_vars/all/resolv_conf.yml
resolv_conf_nameservers:
  - "192.0.2.200"
```

When adding the hosts to FreeIPA generate a random one-time password (OTP), e.g

```shell
ipa host-add --random ...
```

This password must be set as a hostvar `freeipa_host_password`. Once this role
has run (via the `iam.yml` playbook) and enroled hosts this becomes irrelevant
so it should not be committed to Git. A stored keytab takes precedence over
`freeipa_host_password`.

When re-enroling, the host record in FreeIPA host record is updated with the
current hostkey. The `persist_hostkeys` role may be used if rebuilds/reimages
should not change keys.

There are no other role variables in this mode.

### pkinit enrolment mode

1. Set role variables as necessary:
   - `freeipa_servers`: Required. List of FreeIPA server addresses.
   - `node_fqdn`: Required hostvar giving FQDN for each node. Default is set in
     `environments/$ENV/inventory/hosts.yml` by default OpenTofu templates.
   - `freeipa_realm`: Required. Realm to join. Default is set in
     `environments/common/inventory/group_vars/all/freeipa.yml` based on
     cluster name and suffix.
   - `freeipa_domain`: Optional. Domain to join. Default is lowercase of `freeipa_realm`.
   - `freeipa_cert_path`: Optional. Path to directory on localhost containing
     client certs/keys and CA cert. Default `{{ appliances_environment_root }}/freeipa/`.

   Note that:
   - In this mode DNS autodiscovery of FreeIPA servers is disabled.
   - Use of the `resolv_conf` role role may be required to make `freeipa_servers`
     resolvable, e.g. by adding the FreeIPA server IP(s) as nameserver(s).
   - It appears that SSSD still uses DNS to determine its `ipa_server`
     setting, so using a different IPA server for DNS (e.g. a production one for a
     development cluster) will fail; hosts will enrol but SSSD will not be able to
     authenticate.

2. Add the client host certs/keys to `freeipa_cert_path` in the form:
   - `$HOSTNAME.key` for the key
   - `$HOSTNAME.pem` for the certificate

   **NB**: These **MUST** be Ansible Vault encrypted!

3. Add the FreeIPA server's CA certificate to `freeipa_cert_path` as `ca.crt`.

## Defining hosts in FreeIPA

Generally the FreeIPA documentation should be consulted. This section provides
some notes for commands to run on the FreeIPA server - they may not be complete.

- Create a DNS zone for hosts

  ```shell
  ipa dnszone-add $CLUSTER_DNS_ZONE
  ```

  Where $CLUSTER_DNS_ZONE is (jinja) `"{{ openhpc_cluster_name }}.{{ cluster_domain_suffix }}"`

- Create a host in FreeIPA

  ```shell
  echo $FREEIPA_ADMIN_PASSWORD | kinit admin
  ipa host-add $NODE_FQDN --ip-address=$FREEIPA_CLIENT_IP --no-reverse
  ```

The following are specific to pkinit enrolment:

- Generate CSR

  ```shell
  cd /var/lib/ipa/certs/
  openssl req -new -days 3650 -newkey rsa:2048 -nodes \
    -keyout $INVENTORY_HOSTNAME.key -out INVENTORY_HOSTNAME.csr \
    -subj '/CN=$NODE_FQDN/O=$FREEIPA_REALM'
  ```

- Sign the cert

  ```shell
  cd /var/lib/ipa/certs/
  ipa cert-request INVENTORY_HOSTNAME.csr \
    --principal=host/$NODE_FQDN \
    --certificate-out=$INVENTORY_HOSTNAME.pem
  ```

The FreeIPA server cert is available at `/etc/ipa/ca.crt`.
