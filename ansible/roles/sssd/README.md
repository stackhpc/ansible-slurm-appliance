SSSD Role
=========

This is the ansible SSSD role commonly used to configure infrastructure and servers.
It's very basic - just getting the authentication sources right for LDAP, and that's all.

As such, it's typically paired with the nearby openldap role.

Role Variables
--------------

The role takes one main config, sssd_config:

      sssd_config:
        'sssd':
          'config_file_version': '2'
          'debug_level': '5'
          'reconnection_retries': '3'
          'services': 'nss, pam'
          'domains': 'cam'
        'domain/example':
          'auth_provider': 'ldap'
          'ldap_id_use_start_tls': 'False'
          'chpass_provider': 'ldap'
          'cache_credentials': 'True'
          'krb5_realm': 'EXAMPLE.COM'
          'ldap_search_base': "dc=example,dc=com"
          'id_provider': 'ldap'
          'ldap_uri': "ldaps://ldap.example.com"
          'krb5_kdcip': 'kerberos.example.com'
          'ldap_enumeration_refresh_timeout': '43200'
          'ldap_purge_cache_timeout': '0'
          'enumerate': 'true'


Example Playbook
----------------

- name: "Configure SSSD client for user directory/authentication"
  hosts: "all"
  gather_facts: no
  any_errors_fatal: true
  become: true

  roles:
    - role: "sssd"
      sssd_config:
        'sssd':
          'config_file_version': '2'
          'debug_level': '5'
          'reconnection_retries': '3'
...


License
-------

BSD

Author Information
------------------

Original author: Matt Raso-Barnett

Current maintainer: Gwen Dawes
