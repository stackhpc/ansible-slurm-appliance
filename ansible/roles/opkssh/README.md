# opkssh (OpenPubkey SSH)

Install and configure a host for [opkssh](https://github.com/openpubkey/opkssh)
to allow SSH via OIDC identities instead of SSH keys.

This role essentially implements the install and configuration instructions
from the link above, with the following differences:

1. SELinux must be disabled (the appliance default); the installation logic
   to cope with other conditions has not been implemented here.
2. [Per-user policy files](https://github.com/openpubkey/opkssh?tab=readme-ov-file#opkauth_id)
   are not supported, i.e. as if the installer was run with the `--no-home-policy`
   option.
3. By default, `sshd` is configured so keys in user's `~/.ssh/authorized_keys`
   files do NOT permit login, unless user is in a group listed in
   `appliances_admin_user_groups` (default: `[adm]`).
   This is to prevent users provisioning their own keys instead of using OIDC.
4. By default, `sshd` and `ssh` are configured so that SSH connections from this
   host to itself use host-based authentication (instead of user keys or OIDC).
   This allows the OpenOndemand's web shell, which uses SSH, to work as normal.

   > [!IMPORTANT]
   > This requires users to be in the pre-existing `ssh_keys` Linux group.

**NB**: This role does not itself provision Linux users/groups for cluster users.
That should be performed separately as usual, e.g. via [basic_users](ansible/roles/basic_users/README.md)
or [LDAP](ansible/roles/sssd/README.md).

## Enabling

To enable this feature:

1. Build an image including the `opkssh` group, e.g.:

   ```hcl
   # environments/site/builder.pkrvars.hcl:
   inventory_groups = "opkssh"
   ```

   Deploy this to the relevant login node(s).

2. Add the relevant login node(s) to the `opkssh` group, e.g.:

   ```ini
   # environments/site/inventory/groups:
   [opkssh:children]
   login
   ```

Generally role defaults should be satisfactory apart from those described below.

## Role Variables

This section only describes variables which commonly need changing. See `defaults/main.yml`
for all role variables.

- `opkssh_providers`: Optional dict. Allowed OpenID providers (IDPs) to use for auth.
  Keys are a unique label, values are dicts as follows:
  - `issuer_uri`: Required, issuer URI of the IDP.
  - `client_id`: Required, the audience claim in the ID Token.
  - `expires`: Expiration policy. See [opkssh provider docs](https://github.com/openpubkey/opkssh?tab=readme-ov-file#etcopkproviders).

  The default dict has entries for `google`, `microsoft`, `gitlab` and `hello` ([hello.coop](hello.coop)).

- `opkssh_auth_id`: Optional list. Configures which OIDC identities can assume
  which Linux user accounts. Items are dicts as follows:
  - `name`: Required, Linux username.
  - `opkssh_claim_selector`: Required. Selector for OIDC identity claim.
    See [opkssh auth_id docs](https://github.com/openpubkey/opkssh?tab=readme-ov-file#etcopkauth_id),
    for the full syntax, but in brief this could be an email address, a
    unique ID from the `sub` OIDC claim or match against the OIDC `groups`
    claim.
  - `opkssh_provider`: Optional. A key from `opkssh_providers`. Defaults to
    `opkssh_default_provider`.

  The default is an empty list, i.e. no users get access. See configuration hints below.

- `opkssh_default_provider`: Default provider for entries in `opkssh_auth_id`.
  Defaults to first key in `opkssh_providers` (i.e. `google`, by default).

- `opkssh_disable_authorized_keys`: Optional bool. If true, keys in user's
  `~/.ssh/authorized_keys` files do NOT permit login, unless user is in a
  group listed in `opkssh_enable_authorized_keys_groups`. Default `true`.

- `opkssh_enable_authorized_keys_groups`: Optional list. Linux groups for which
  keys in the user's authorized_keys files do permit login. Default is the same
  as `appliances_admin_user_groups`, which includes the `rocky` user. This is
  necessary to allow Ansible to configure the cluster.

- `opkssh_configure_hostbased_auth`: Optional bool. If true, configure `sshd`
  and `ssh` so that SSH connections from this host to itself use host-based
  authentication, if the user is in the `ssh_keys` group. Default `true`,
  allows the OpenOndemand's web shell to work as normal.

## Usage Hints

To connect to the cluster users should follow the opkssh docs, but note that:

1. The SSH user `ssh user@...` should be their _Linux_ user, as normal, not
   their OIDC identity.
2. If login fails with the error "Too many authentication failures" then limit
   the SSH client to only using the key printed by `opkssh login`, e.g.:

   ```shell
   ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ecdsa user@host
   ```

3. If this role is enabled on `login` nodes but not compute nodes, if a user
   has an SSH private key in their `~/.ssh` directory and the corresponding
   public key in their `~/.ssh/authorized_keys` file (e.g. if using the `basic_users`
   role their `basic_users_users` entry has `generate_ssh_key: true`), then they
   will be able to SSH from the login node to a compute node (subject to them having
   a running job on that node) as usual.

## Configuration Hints

If using the `basic_users` role to provision Linux users, the `opkssh_auth_id`
variable can be derived from the `basic_user_users` variable (which accepts
arbitrary additional keys/values in entries) by filtering out ones which are not
valid `opkssh_auth_id` entries. E.g.:

```yaml
basic_users_users:
  - name: demo_user_oidc
    uid: 1005
    groups:
      - ssh_keys # required for ondemand web shell, see above
    opkssh_claim_selector: janedoe@example.com
  ...

opkssh_auth_id: "{{ basic_users_users | select('contains', 'opkssh_claim_selector') }}"
```
