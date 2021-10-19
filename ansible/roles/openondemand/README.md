# Role Name

A brief description of the role goes here.

## Requirements

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

## Role Variables

### **NEW** variables added by this role
- `ood_dashboard_support_url`: Optional. URL or email etc to show as support contact under Help in dashboard. Default `(undefined)`.
- `ood_dashboard_docs_url`: Optional. URL of docs to show under Help in dashboard. Default `(undefined)`.


### `osc.ood-ansible` variables **overriden** by this role
- `ssl_cert`: /etc/pki/tls/certs/localhost.crt
- `ssl_cert_key`: /etc/pki/tls/private/localhost.key


# TODO: document how to configure for OIDC:


servername: # Leave this EMPTY if accessing server by IP (overrides default of "localhost" from ansible/roles/osc.ood/defaults/main/ood_portal.yml which isn't helpful)


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
