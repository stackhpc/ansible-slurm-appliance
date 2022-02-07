ansible_ipa_ldap_fix
====================

installs base packages and sets TLS_REQSAN allow to get around ldap vs RedHat ipa missing a SAN in SSL cert.

Requirements
------------
Tested on Rocky Linux 8. Should work on Stream 8, RHEL 8, or ubuntu 20.04+

Role Variables
--------------

None, really.

Dependencies
------------

n/a

Example Playbook
----------------

Something like:

    - hosts: all:!switches:!not_linux
      roles:
         - { role: ansible_ipa_ldap_fix }

License
-------

GPL 2.0 or later

Author Information
------------------

Blame Kurt.

