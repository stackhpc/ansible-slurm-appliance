mysql
=====

Deploy containerised `mysql` server using Podman.


Requirements
------------

None.

Role Variables
--------------

- `mysql_root_password`: Required str. Password to set for `root` mysql user. **NB** This cannot be changed by this role once mysql server has initialised.
- `mysql_tag`: Optional str. Tag for version of `mysql` container image to use. Default `8.0.30`.
- `mysql_enabled`: Optional bool. Whether `mysql` service starts on boot. Default `yes`.
- `mysql_state`: Optional str. As per `ansible.builtin.systemd:state`. Default is `started` or `restarted` as required.
- `mysql_podman_user`: Optional str. User running `podman`. Default `{{ ansible_user }}`.
- `mysql_datadir`: Optional str. Path to data directory to store databases etc. Default `/var/lib/mysql`. Note all path components will be created and user set appropriately if this does not exist.
- `mysql_host`: Optional str. Address of host. Default `{{ inventory_hostname }}`.
- `mysql_user_login_details`: Optional. As required for `community.mysql.mysql_db` to connect to mysql server as the root user. See `defaults/main.yml`.
- `mysql_db_login_details`: Optional. As required for `community.mysql.mysql_user` to connect to mysql server as the root user. See `defaults/main.yml`.
- `mysql_users`: Optional list of dicts defining users as per `community.mysql.mysql_user`. Default `[]`. Note `mysql_user_login_details` sets some defaults.
- `mysql_databases`: Optional list of dicts defining databases as per `community.mysql.mysql_db`. Default `[]`. Note `mysql_db_login_details` sets some defaults.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Setup DB
  hosts: mysql
  become: true
  tags:
    - mysql
  tasks:
    - include_role:
        name:  mysql
```

License
-------

Apache v2

Author Information
------------------

Steve Brasier steveb@stackhpc.com
