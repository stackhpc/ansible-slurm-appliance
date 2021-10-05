rebuild
=======

Enable the compute nodes to be reimaged from Slurm. To use this functionality add the `control` and `compute` groups to the `rebuild` group.

Once `ansible/slurm.yml` has run, node(s) can be reimaged using:

    scontrol reboot [ASAP] [nextstate=<RESUME|DOWN>] reason="rebuild image:<image_id>" [<NODES>]

where:
- `<image_id>` is the name (if unique) or ID of an image in OpenStack.
- `<NODES>` is a Slurm hostlist expression defining the nodes to reimage.
- `ASAP` means the rebuild will happen as soon as existing jobs on the node(s) complete - no new jobs will be scheduled on it.
- If `nextstate=...` is not given nodes remain in DRAIN state after the rebuild.

Requirements
------------

- This role must be run before the `stackhpc.openhpc` role's `runtime.yml` playbook as it modifies the `openhpc_config` variable.
- OpenStack credentials on the compute nodes, e.g. at `/etc/openstack/clouds.yaml` which are readable by the root user. It is recommended these credentials are an [application credential](https://docs.openstack.org/keystone/latest/user/application_credentials.html). This can be created in Horizon via Identity > Application Credentials > +Create Application Credential. The usual role required is `member`. Using access rules has been found not to work at present. Note that the downloaded credential can be encrpyted using `ansible-vault` to allow commit to source control. It will automatically be decrypted when copied onto the compute nodes.
- An image which when booted adds that node to the Slurm cluster. E.g. see `packer/README.md`.

Role Variables
--------------

None normally required.

Dependencies
------------

See above.

Example Playbook
----------------

See `ansible/slurm.yml`


License
-------

Apache v2

Author Information
------------------

StackHPC Ltd.
