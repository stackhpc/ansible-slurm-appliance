# Role Name

A brief description of the role goes here.

TODO:
- Support PAM auth (as default when basic_users available??): https://osc.github.io/ood-documentation/latest/authentication/pam.html

## Requirements

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

**NB**: Open Ondemand's relies on mapping authenticated users to local users on the `openondemand` node (e.g. by using `openondemand_mapping_users` or other mechanisms TODO: docs link). You must therefore ensure that whatever is providing users for the cluster covers the `openondemand` node, e.g. if using `basic_users` role ensure the group for this includes the `openondemand` group.

## Role Variables

TODO: make names consistent here!
- `openondemand_dashboard_support_url`: Optional. URL or email etc to show as support contact under Help in dashboard. Default `(undefined)`.
- `openondemand_dashboard_docs_url`: Optional. URL of docs to show under Help in dashboard. Default `(undefined)`.
- `openondemand_mapping_users`: Optional. A list of dicts defining users to map (TODO ADD DOCS REFERENCE). Each dict should have keys `name` and `authenticated_username` giving the local and remote usernames respectively. TODO: describe what this turns on. TODO: should this be `openondemand_username` or something?

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
