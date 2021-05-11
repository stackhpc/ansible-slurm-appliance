stackhpc.os-manila-mount
========================

[![Build Status](https://www.travis-ci.org/stackhpc/ansible-role-os-manila-mount.svg?branch=master)](https://www.travis-ci.org/stackhpc/ansible-role-os-manila-mount)

Mount a share created by OpenStack Manila.

Currently only supports CephFS. We have plans to add GlusterFS.

Requirements
------------

This role only requires Ansible.

Role Variables
--------------

* `os_manila_mount_action`: Action to perform with Manila.  Options are
  `lookup`, `mount`.  Default is `mount`.

Lookup mode
===========

`lookup` mode retrieves share server address and other data, as a fact-gathering
exercise.  This operation must be performed on hosts that have access to the
OpenStack APIs.

Options applicable when working in `lookup` mode:

* `os_manila_mount_share_user`: User name for mount access check.
* `os_manila_mount_share_protocol`: Filesystem type to look up.  Currently 
  supported options are `CEPHFS`.
* `os_manila_mount_auth_type`: Can be `cloud` (default) or `password.
* `os_manila_mount_os_config_name`: Cloud config name when auth type is `cloud`,
  as defined in `/etc/openstack/clouds.yaml`
* `os_manila_mount_auth`: OpenStack credentials when auth type is `password.  
* `os_manila_mount_configurations`: Mapping-of-mappings describing each share to mount. Keys are the Manila name for the share (as in output of `manila list`). Values may be empty maps in this mode.


The following facts are set by this module:

* `os_manila_mount_facts`: Mapping of mappings where keys are the Manila name for the share and values are mappings containing keys:
  * `host`: The server to contact for mounting the share.
  * `export`: The path on the server from which the share is exported.
  * `access_key`: The secret to use when mounting the share.

Mount mode
==========

`mount` mode retrieves share data (if a previous invocation of `lookup` had not
gathered the required facts) and performs the mount action.  If `lookup` has not
previously been invoked, access to the OpenStack APIs will be required.

When working in `mount` mode when a lookup has not previously been performed, the options applicable in lookup mode as above are also applicable.

In either case, the following key/value pairs must be set in the mappings in `os_manila_mount_configurations`:

* `mount_path`: Mount point on the client for this share.
* `mount_user`: User by which the mount point should be owned.
* `mount_group`: Group by which the mount point should be owned

Ceph package repo and configuration options:

* `os_manila_mount_ceph_version`: Version of Ceph client package to install. Default `octopus`.
* `os_manila_mount_state`: State of mounts, default `mounted`, See Ansible `mount` module parameter `state` for options.
* `os_manila_mount_pkgs_install`: Install repos and client packages needed for Ceph?
  Defaults to `True`.
* `os_manila_mount_ceph_repo_base`: Package repository to use.
  Default is `http://mirror.centos.org/centos/$releasever/storage/x86_64/ceph-{{ os_manila_mount_ceph_version }/`.
* `os_manila_mount_ceph_repo_key`: Repo signing GPG key.
  Default is `https://raw.githubusercontent.com/CentOS-Storage-SIG/centos-release-storage-common/master/RPM-GPG-KEY-CentOS-SIG-Storage`
* `os_manila_mount_ceph_conf_path`: Path to Ceph cluster configuration file.
  Default is `/etc/ceph`.


Dependencies
------------

When mounting a Manila-orchestrated share in one step, this role depends on
OpenStack configuration being placed at `/etc/openstack/clouds.yaml`
One way to do that is using the role ``stackhpc.os-config``.

Example Playbook
----------------

This example pulls a few things together so you push the OpenStack config,
and then mount a preexisting manila share:

    ---
    - hosts: all
      vars:
        my_cloud_config: |
          ---
          clouds:
            mycloud:
              auth:
                auth_url: http://openstack.example.com:5000
                project_name: p3
                username: user
                password: secretpassword
              region: RegionOne
      roles:
        - { role: stackhpc.os-config,
            os_config_content: "{{ my_cloud_config }}" }
        - { role: stackhpc.os-manila-mount,
            os_manila_mount_action: "lookup"
            os_manila_mount_os_config_name: "mycloud",
            os_manila_mount_share_name: my-share,
            os_manila_mount_share_user: fakeuser }

An easy way to this example is:

    sudo yum install python-virtualenv libselinux-python

    virtualenv .venv --system-site-packages
    . .venv/bin/activate
    pip install -U pip
    pip install -U ansible

    ansible-galaxy install stackhpc.os-manila-mount \
                           stackhpc.os-config

    ansible-playbook -i "localhost," -c local test.yml

A second example in which the querying of the OpenStack APIs is done once,
from the local system. Note that password based authentication is used in this
scenario. The group of nodes that mount the shared filesystem share the data
returned:

    ---
    # Query OpenStack Manila for details aob
    - hosts: localhost
      roles:
        - role: stackhpc.os-manila-mount
          os_manila_mount_action: "lookup"
          os_manila_mount_share_name: "HomeDirs"
          os_manila_mount_share_user: "home"
          os_manila_mount_auth_type: "password"
          os_manila_mount_auth:
            project_domain_name: fake-project-domain
            user_domain_name: fake-user-domain
            project_name: fake-project
            username: fakeuser
            password: fakepassword
            auth_url: http://fake-auth-url

    - hosts: cluster_ceph_client
      roles:
        # Perform the mount action on all Ceph client nodes
        - role: stackhpc.os-manila-mount
          os_manila_mount_action: "mount"
          os_manila_mount_host: "{{ hostvars['localhost']['os_manila_mount_host'] }}"
          os_manila_mount_access_key: "{{ hostvars['localhost']['os_manila_mount_access_key'] }}"
          os_manila_mount_export: "{{ hostvars['localhost']['os_manila_mount_export'] }}"
          os_manila_mount_share_user: "home"
          os_manila_mount_pkgs_install: True
          os_manila_mount_path: "/var/mnt/ceph"
          os_manila_mount_user: "root"
          os_manila_mount_group: "root"
          os_manila_mount_fuse: True


License
-------

Apache

Author Information
------------------

http://www.stackhpc.com
