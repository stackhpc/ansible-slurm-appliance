
basic_users
===========

Setup users on cluster nodes using `/etc/passwd` and manipulating `$HOME`, i.e.
without requiring LDAP etc. Features:
- UID/GID is consistent across cluster (and explicitly defined).
- SSH key generated and propagated to all nodes to allow login between cluster nodes.
- An "external" SSH key can be added to allow login from elsewhere.
- Login to the control node is prevented (by default).
- When deleting users, systemd user sessions are terminated first.

> [!IMPORTANT] This role assumes that `$HOME` for users managed by this role 
(e.g. not `rocky` and other system users) is on a shared filesystem. The export
of this sharef filesystem may be root squashed if the server is in the
`basic_user` group - see configuration advice below.

Role Variables
--------------

- `basic_users_users`: Optional, default empty list. A list of mappings defining information for each user. In general, mapping keys/values are passed through as parameters to [ansible.builtin.user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) and default values are as given there. However:
  - `create_home` and `generate_ssh_key`: Normally set automatically. Can be
    set `false` if necessary to disable home directory creation or cluster ssh
    key creation, should not be set `true`.
  - `ssh_key_comment`: Default is user name.
  - `home`: Normally set automatically.
  - `uid` should be set, so that the UID/GID is consistent across the cluster
    (which Slurm requires).
  - `shell` If *not* set will be `/sbin/nologin` on the `control` node and the
     default shell on other users. Explicitly setting this defines the shell for
     all nodes.
  - An additional key `public_key` may optionally be specified to define a key to log into the cluster.
  - An additional key `sudo` may optionally be specified giving a string (possibly multiline) defining sudo rules to be templated.
  - `ssh_key_type` defaults to `ed25519` instead of the `ansible.builtin.user` default of `rsa`.
  - Any other keys may present for other purposes (i.e. not used by this role).
- `basic_users_groups`: Optional, default empty list. A list of mappings defining information for each group. Mapping keys/values are passed through as parameters to [ansible.builtin.group](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html) and default values are as given there.
- `basic_users_override_sssd`: Optional bool, default false. Whether to disable `sssd` when ensuring users/groups exist with this role. Permits creating local users/groups even if they clash with users provided via sssd (e.g. from LDAP). Ignored if host is not in group `sssd` as well. Note with this option active `sssd` will be stopped and restarted each time this role is run.
- `basic_users_homedir_host`: Optional inventory hostname. Host to run actions
  which manipulate the home directories. If home directories are exported with
  root squash, this *must* specify that server. If root squash is not used it
  can be any node in the `basic_users` group. Default is the `control` node,
  which assumes the default appliance NFS-exported home directory configuration.
- `basic_users_homedir_host_path`: Optional path prefix for home directories on
   the `basic_users_homedir_host`. Default is `/exports/home` which assumes the
   default appliance NFS-exported home directory configuration. **NB**: This may
   vary depending on whether
   `basic_users_homedir_host` is a server or a client for the home directories.

Dependencies
------------

None.

Example Configurations
----------------------

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

Using an external share which does not root squash so this role can create
directories on it, which is also mounted to the control node (so this role can
set authorized keys there), create user `Carol`:

```yaml
basic_users_homedir_host: "{{ ansible_play_hosts | first }}" # doesn't matter which host is used
basic_users_homedir_host_path: /home # homedir_host is client not server
basic_users_user:
  - comment: Carol Crane
    name: carol
    uid: 2007
    public_key: ssh-ed25519 ...
```

Using an external share which *does* root squash, so home directories cannot be
created by this role and must already exist, create user `Dan`:

```yaml
basic_users_homedir_host: "{{ ansible_play_hosts | first }}"
basic_users_homedir_host_path: /home
basic_users_users:
  - comment: Dan Deer
    create_home: false
    name: dan
    uuid: 2009
    public_key: ssh-ed25519 ...
```

Using NFS exported from the control node, but mounted to all nodes (so that
authorized keys applies to all nodes), create user `Erin` with passwordless sudo:

```yaml
basic_users_users:
  - comment: Erin Eagle
    name: dan
    uid: 2008
    shell: /bin/bash # override default nologin on control
    groups:
      - adm # enables ssh to compute nodes even without a job running
    sudo: dan ALL=(ALL) NOPASSWD:ALL
    public_key: ssh-ed25519 ...
```
