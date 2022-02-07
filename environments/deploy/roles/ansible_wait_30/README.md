pause_for_30
============

Will pause execution for 30 seconds by default. See the `pause_for_secs` var to customise your delay time.

Requirements
------------

Willingness to wait.

Role Variables
--------------

### pause_for_secs

You can pass the `pause_for_secs` at the command prompt to customize the # of seconds you want to pause to last. Example:

    -e pause_for_secs=120

Dependencies
------------

none

Example Playbook
----------------

    - hosts: whatever
      roles:
         - { role: pause_for_30 }

License
-------

GPL 2.0 or later

Author Information
------------------

Blame this on Kurt.
