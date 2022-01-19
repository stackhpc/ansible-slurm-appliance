# Packer-based image build

This workflow uses Packer with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build compute and login node images. These images can be used during cluster creation or to update an existing cluster. Building images reduces the number of package downloads when deploying a large cluster, and ensures that nodes can be recreated even if packages have changed in repos (e.g. due to CentOS or OpenHPC updates).

Packer creates OpenStack VMs and configures them by running `ansible/site.yml`, as for direct configuration. However (by default) in Packer builds a `yum update *` step is run, which is not the default when running ansible directly to avoid modifying existing nodes. Packer will upload the resulting images to OpenStack with a name including a timestamp.

As configuring slurm deamons require the control hostname (as may other features such as NFS mounts), building login and control images requires that the control node is deployed, although it does not need to be configured. Note that control node images cannot [currently](https://github.com/stackhpc/ansible-slurm-appliance/issues/133) be created.

Steps:

- Create an application credential with sufficient authorisation to upload images (this may or may not be the `member` role, depending on your OpenStack configuration).
- Create a file `environments/<environment>/builder.pkrvars.hcl` containing at a minimum e.g.:
  
  ```hcl
  flavor = "general.v1.small"                           # VM flavor to use for builder VMs
  networks = ["26023e3d-bc8e-459c-8def-dbd47ab01756"]   # List of network UUIDs to attach the VM to
  source_image_name = "Rocky-8.5-GenericCloud"          # Name of source image. This must exist in OpenStack and should be a Rocky Linux 8.5 GenericCloud-based image.
  ssh_keypair_name = "slurm-app-ci"                     # Name of an existing keypair in OpenStack. The private key must be on the host running Packer.
  ```
  
  The network(s) used for the Packer VMs must provide for outbound internet access but do not need to provide access to resources which the final cluster nodes require (e.g. Slurm control node, network filesystem servers etc.). These items are configured but not enabled in the Packer VMs.
  
  For additional options (e.g. non-default private key locations) see the variable descriptions in `./openstack.pkr.hcl`.

- Activate the venv and the relevant environment.
- Ensure you have generated passwords using:

        ansible-playbook ansible/adhoc/generate-passwords.yml

- Ensure you have the private part of the keypair `ssh_keypair_name` at `~/.ssh/id_rsa.pub` (or set variable `ssh_private_key_file` in `builder.pkrvars.hcl`).

- Ensure a control node is deployed, following the main `README.md`. Note variable `openhpc_slurm_partitions` ([docs](https://github.com/stackhpc/ansible-role-openhpc/#slurmconf)) must define a (non-empty) partition configuration, but this partition configuration does not actually affect the compute/login node images so e.g. a smaller cluster may be deployed for development and image build.

- Build images using the variable definition file:

        cd packer
        PACKER_LOG=1 packer build -on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

  Note the builder VMs are added to the `builder` group to differentiate them from "real" nodes - see developer notes below.

# Notes for developers

The Packer build VMs are added to both the `builder` group and the `login` or `compute` groups as appropriate. The former group allows `environments/common/inventory/group_vars/builder/defaults.yml` to set variables specifically for the VM where the real cluster may not be contactable (depending on the build network used). Currently this means:
- Enabling but not starting `slurmd`.
- Setting NFS mounts to `present` but not `mounted`

Note that in this appliance the munge key is pre-created in the environment's "all" group vars, so this aspect needs no special handling.

Ansible may need to proxy to the compute nodes. If the Packer build should not use the same proxy to connect to the builder VMs, proxy configuration should not be added to the `all` group.
