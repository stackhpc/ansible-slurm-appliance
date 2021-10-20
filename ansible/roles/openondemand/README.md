# Role Name

A brief description of the role goes here.

TODO:
- Support PAM auth (as default when basic_users available??): https://osc.github.io/ood-documentation/latest/authentication/pam.html

## Requirements

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

## Role Variables

### **NEW** variables added by this role
# TODO: make names consistent here!
- `openondemand_dashboard_support_url`: Optional. URL or email etc to show as support contact under Help in dashboard. Default `(undefined)`.
- `openondemand_dashboard_docs_url`: Optional. URL of docs to show under Help in dashboard. Default `(undefined)`.
- `openondemand_mapping_users`: Optional. A list of dicts defining users to map (TODO ADD DOCS REFERENCE). Each dict should have keys `name` and `authenticated_username` giving the local and remote usernames respectively. TODO: describe what this turns on.

### `osc.ood-ansible` variables **overriden** by this role
These are prefixed ood_ (if not present already) - and MUST be overriden using the prefixed version (not sure this is the best way, TBH)
- `ssl_cert`: /etc/pki/tls/certs/localhost.crt
- `ssl_cert_key`: /etc/pki/tls/private/localhost.key

### EXTRA functionality:
- If there is a non-empty `basic_users` group and `user_map_cmd` is set to `ood_auth_map.mapfile` then TODO: ...


# TODO: document how to configure for OIDC:
Basically needs this:

```yaml
servername: # Leave this EMPTY if accessing server by IP (overrides default of "localhost" from ansible/roles/osc.ood/defaults/main/ood_portal.yml which isn't helpful)
oidc_uri: /oidc # this needs to be set separately to trigger the oidc integration!
ood_auth_openidc: # see https://github.com/zmartzone/mod_auth_openidc for instructions here
# but set all the things in # https://osc.github.io/ood-documentation/latest/authentication/oidc.html#openid-connect
  OIDCRedirectURI: "https://<openondemand_server_addr>{{ oidc_uri }}"
  OIDCClientID: <secret> # from OIDC provider
  OIDCClientSecret: <secret> # from OIDC provider
  OIDCProviderMetadataURL: https://my-oidc-provider.com/.well-known/openid-configuration # e.g.
  OIDCCryptoPassphrase: <secret> # randomly generated
  OIDCSSLValidateServer: "Off" # NB: has to be quoted to avoid conversion to True/False
  OIDCPassClaimsAs: environment
  OIDCPassIDTokenAs: serialized
  OIDCScope: openid profile preferred_username
  OIDCPassRefreshToken: "On" # NB: has to be quoted to avoid conversion to True/False
  OIDCStripCookies: mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1
  OIDCRemoteUserClaim: preferred_username
httpd_auth: # ood_portal.yml.j2 # TODO: change name??
  - 'AuthType openid-connect'
  - 'Require valid-user'
```

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
