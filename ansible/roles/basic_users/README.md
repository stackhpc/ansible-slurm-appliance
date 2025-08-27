# basic_users

Setup users on cluster nodes using `/etc/passwd` and manipulating `$HOME`, i.e.
without requiring LDAP etc. Features:

- UID/GID is consistent across cluster (and explicitly defined).
- SSH key generated and propagated to all nodes to allow login between cluster
  nodes.
- An "external" SSH key can be added to allow login from elsewhere.
- Login to the control node is prevented (by default).
- When deleting users, systemd user sessions are terminated first.

> [!IMPORTANT] The defaults for this role assumes that `$HOME` for users
> managed by this role (e.g. not `rocky` and other system users) is on a shared
> filesystem. The export of this shared filesystem may be root squashed if its
> server is in the `basic_user` group - see configuration examples below.

## Role Variables

- `basic_users_homedir_server`: Optional inventory hostname in the `basic_users`
  group defining the host to use to create home directories. If the home
  directory export is root squashed, this host _must_ be the home directory
  server. Default is the `control` node which is appropriate for the default
  appliance configuration. Not relevant if `create_home` is false for all users.
- `basic_users_homedir_server_path`: Optional path prefix for home directories on
  the `basic_users_homedir_server`, i.e. on the "server-side". Default is
  `/exports/home` which is appropriate for the default appliance configuration.
- `basic_users_homedir_client`: Optional inventory hostname in the `basic_users`
  group defining the host to use to create SSH keys etc in home directories.
  This should be a host mounting the home directories. Default is the first
  node in the `login` group which is appropriate for the default appliance
  configuration.
- `basic_users_users`: Optional, default empty list. A list of mappings defining
  information for each user. In general, mapping keys/values are passed through
  as parameters to [ansible.builtin.user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)
  and default values are as given there, with the following differences:
  - `generate_ssh_key`: Default is `true`, and the generated key is added to
    the user's authorized keys.
  - `ssh_key_comment`: Default is username.
  - `home`: Set automatically based on the username and
    `basic_users_homedir_server_path`. Can be overriden for users with
    non-standard home directory paths.
  - `uid`: Should be set, so that the UID/GID is consistent across the cluster
    (which Slurm requires).
  - `shell`: If _not_ set will be `/sbin/nologin` on the `control` node to
    prevent users logging in to this node, and the default shell on other
    nodes. Explicitly setting this defines the shell for all nodes and if the
    shared home directories are mounted on the control node will allow the
    user to log in to the control node.
  - `public_key`: Optional, define a key to log into the cluster with.
  - `sudo`: Optional, a (possibly multiline) string defining sudo rules for the
    user.
  - `ssh_key_type` defaults to `ed25519` instead of the `ansible.builtin.user`
    default of `rsa`.
  - Any other keys may present for other purposes (i.e. not used by this role).
- `basic_users_groups`: Optional, default empty list. A list of mappings defining information for each group. Mapping keys/values are passed through as parameters to [ansible.builtin.group](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html) and default values are as given there.
- `basic_users_override_sssd`: Optional bool, default false. Whether to disable `sssd` when ensuring users/groups exist with this role. Permits creating local users/groups even if they clash with users provided via sssd (e.g. from LDAP). Ignored if host is not in group `sssd` as well. Note with this option active `sssd` will be stopped and restarted each time this role is run.

## Dependencies

None.

## Example Configurations

With default appliance NFS configuration, create user `alice` with access
to all nodes except the control node, and delete user `bob`:

```yaml
basic_users_users:
  - comment: Alice Aardvark
    name: alice
    uid: 2005
    public_key: ssh-ed25519 ...
  - comment: Bob Badger
    name: bob
    uid: 2006
    public_key: ssh-ed25519 ...
    state: absent
```

Using an external share which:

- does not root squash (so this role can create directories on it)
- is mounted to all nodes including the control node (so this role can set
  authorized keys there)

Create user `Carol`:

```yaml
basic_users_homedir_host: "{{ ansible_play_hosts | first }}" # doesn't matter which host is used
basic_users_homedir_host_path: /home # homedir_host is client not server
basic_users_user:
  - comment: Carol Crane
    name: carol
    uid: 2007
    public_key: ssh-ed25519 ...
```

Using an external share which _does_ root squash, so home directories cannot be
created by this role and must already exist, create user `Dan`:

```yaml
basic_users_homedir_host: "{{ ansible_play_hosts | first }}"
basic_users_homedir_host_path: /home
basic_users_users:
  - comment: Dan Deer
    create_home: false
    name: dan
    uuid: 2008
    public_key: ssh-ed25519 ...
```

Using NFS exported from the control node, but mounted to all nodes (so that
authorized keys applies to all nodes), create user `Erin` with passwordless sudo:

```yaml
basic_users_users:
  - comment: Erin Eagle
    name: erin
    uid: 2009
    shell: /bin/bash # override default nologin on control
    groups:
      - adm # enables ssh to compute nodes even without a job running
    sudo: erin ALL=(ALL) NOPASSWD:ALL
    public_key: ssh-ed25519 ...
```
