root_pass_cli
=============

Set the root password. Must pass the new_root_pass and ROOT_TARGETS vars. See below.

If you want to be prompted for a passwd, use the `root_pass_prompt` playbook/role.

Requirements
------------

You must define hosts in the `ROOT_TARGETS` variable and a password, e.g.,

    -e ROOT_TARGETS=foo.hpc.nrel.gov -e new_root_pass=XXXXX_SOME_PASS_XXXX

...on the command line

You must know the password, as you'l have to type it twice.

Role Variables
--------------

*** ROOT_TARGETS
Use a host, host glob, or grouop name:

    -e ROOT_TARGETS=host.hpc.nrel.gov
    -e ROOT_TARGETS=opstest-*,ops-foo-0*.hpc.nrel.gov
    -e ROOT_TARGETS=DAVPROD

*** new_root_pass
Also pass the new root password:

    -e new_root_pass=DONOTUSETHISUNLESSYOUARESURE

Dependencies
------------

None

Example Playbook
----------------

    ansible-playbook ./root_pass -e ROOT_TARGETS=your-servers-or-group -e new_root_pass=XXXXXX

License
-------

GPL 2.0 or later

Author Information
------------------

Blame this on Kurt.
