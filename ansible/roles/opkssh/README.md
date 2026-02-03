# opkssh (OpenPubkey SSH)

Install and configure a host for [opkssh](https://github.com/openpubkey/opkssh)
to allow ssh via OIDC identities instead of SSH keys.

**NB**: This does not itself provision the required Linux users/groups - that
should be performed as usual, e.g. via [LDAP](ansible/roles/sssd/README.md) or
[basic_users](ansible/roles/basic_users/README.md).

This role basically implements the install and configuration instructions
from the link above, with the following limitations:
1. SELinux must be disabled (the appliance default); the installation logic
   to cope with other conditions has not been implemented here.
2. [Per-user policy files](https://github.com/openpubkey/opkssh?tab=readme-ov-file#opkauth_id)
   are not supported, i.e. as if the installer was run with the `--no-home-policy`
   option.

## Role variables


## Usage

Users should follow the opkssh docs, but note that:
1. The ssh user `ssh user@...` should be their system user, as normal, not their
   OIDC identity.
2. If login fails with the error "Too many authentication failures" then restrict
   ssh to only using the key printed by `opkssh login`, e.g.:

    ```shell
    ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ecdsa user@host
    ```

- TODO: fatimage
- TODO: disable user keys etc
