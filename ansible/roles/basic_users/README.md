
basic_users
===========

Setup users on cluster nodes using `/etc/passwd` and manipulating `$HOME`, i.e.
without requiring LDAP etc. Features:
- UID/GID is consistent across cluster (and explicitly defined).
- SSH key generated and propagated to all nodes to allow login between cluster nodes.
- An "external" SSH key can be added to allow login from elsewhere.
- Login to the control node is prevented (by default)
- When deleting users, systemd user sessions are terminated first.

Requirements
------------
- `$HOME` (for normal users, i.e. not `rocky`) is assumed to be on a shared
  filesystem. Actions affecting that shared filesystem are run on a single host,
  see `basic_users_manage_homedir` below.

Role Variables
--------------

- `basic_users_users`: Optional, default empty list. A list of mappings defining information for each user. In general, mapping keys/values are passed through as parameters to [ansible.builtin.user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) and default values are as given there. However:
  - `create_home`, `generate_ssh_key` and `ssh_key_comment` are set automatically; this assumes home directories are on a cluster-shared filesystem.
  - `uid` should be set, so that the UID/GID is consistent across the cluster (which Slurm requires).
  - `shell` if *not* set will be `/sbin/nologin` on the `control` node and the default shell on other users. Explicitly setting this defines the shell for all nodes.
  - An additional key `public_key` may optionally be specified to define a key to log into the cluster.
  - An additional key `sudo` may optionally be specified giving a string (possibly multiline) defining sudo rules to be templated.
  - `ssh_key_type` defaults to `ed25519` instead of the `ansible.builtin.user` default of `rsa`.
  - Any other keys may present for other purposes (i.e. not used by this role).
- `basic_users_groups`: Optional, default empty list. A list of mappings defining information for each group. Mapping keys/values are passed through as parameters to [ansible.builtin.group](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html) and default values are as given there.
- `basic_users_override_sssd`: Optional bool, default false. Whether to disable `sssd` when ensuring users/groups exist with this role. Permits creating local users/groups even if they clash with users provided via sssd (e.g. from LDAP). Ignored if host is not in group `sssd` as well. Note with this option active `sssd` will be stopped and restarted each time this role is run.
- `basic_users_manage_homedir`: Optional bool, must be true on a single host to
  determine which host runs tasks affecting the shared filesystem. The default
  is to use the first play host which is not the control node, because the
  default NFS configuration does not have the shared `/home` directory mounted
  on the control node.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: basic_users
  become: yes
  gather_facts: yes
  tasks:
    - import_role:
        name: basic_users
```

Example variables, to create user `alice` and delete user `bob`:

```yaml
basic_users_users:
  - comment: Alice Aardvark
    name: alice
    uid: 2005
    public_key: ssh-rsa ...
  - comment: Bob Badger
    name: bob
    uid: 2006
    public_key: ssh-rsa ...
    state: absent
```
