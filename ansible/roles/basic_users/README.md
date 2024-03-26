
basic_users
===========

Setup users on cluster nodes using `/etc/passwd` and manipulating `$HOME`, i.e. without requiring LDAP etc. Features:
- UID/GID is consistent across cluster (and explicitly defined).
- SSH key generated and propagated to all nodes to allow login between cluster nodes.
- An "external" SSH key can be added to allow login from elsewhere.
- Login to the control node is prevented.
- When deleting users, systemd user sessions are terminated first.

Requirements
------------
- $HOME (for normal users, i.e. not `centos`) is assumed to be on a shared filesystem.

Role Variables
--------------

`basic_users_users`: Required. A list of mappings defining information for each user. In general, mapping keys/values are passed through as parameters to [ansible.builtin.user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html) and default values are as given there. However:
- `create_home`, `generate_ssh_key` and `ssh_key_comment` are set automatically and should not be overriden.
- `uid` should be set, so that the UID/GID is consistent across the cluster (which Slurm requires).
- `shell` if *not* set will be `/sbin/nologin` on the `control` node and the default shell on other users. Explicitly setting this defines the shell for all nodes.
- An additional key `public_key` may optionally be specified to define a key to log into the cluster.
- Any other keys may present for other purposes (i.e. not used by this role).

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
