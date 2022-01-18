# Packer-based image build

This workflow uses Packer with the [OpenStack builder](https://www.packer.io/plugins/builders/openstack) to build compute and login node images by:
- Creating OpenStack VMs.
- Running the same `ansible/site.yml` playbook as for direct ansible configuration, except that (by default) a `yum update *` is run.
- Capturing and converting images.
- Uploading the images to OpenStack.

These images can be used to create a new cluster, or to reimage an existing cluster with updated images (see the [Slurm-controlled rebuild functionality](ansible/collections/ansible_collections/stackhpc/slurm_openstack_tools/roles/rebuild/README.md) and the [ad-hoc reimage playbook](ansible/adhoc/rebuild.yml).

The benefits of deploying a cluster using images instead of running ansible directly against nodes are that:
- Deploying multiple compute nodes only requires package downloads to be done once, instead of once per compute node.
- Compute and login nodes can be recreated exactly as-is, even if packages in the various repos used (Rocky/EPEL/OpenHPC) have changed.

Note that control node images cannot currently be created and hence the control node must be configured using ansible directly.

Steps:

- Create an application credential with sufficent authorisation to upload images (this may or may not be the `member` role, depending on your OpenStack configuration).
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

- Build images using the variable definition file:

        cd packer
        PACKER_LOG=1 packer build -on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

  Note the builder VMs are added to the `builder` group to differentiate them from "real" nodes - see developer notes below.

# Notes for developers

The Packer build VMs are added to both the `builder` group and the `login` or `compute` groups as appropriate. The former group allows `environments/common/inventory/group_vars/builder/defaults.yml` to set variables specifically for the VM where the real cluster may not be contactable (depending on where the build network). Currently this means:
- Enabling but not starting `slurmd`.
- Setting NFS mounts to `present` but not `mounted`

Note that in this appliance the munge key is pre-created in the environment's "all" group vars, so this aspect needs no special handling.

Some more subtle points to note if developing code based off this:
- In general, you should assume that ansible needs to ssh proxy to the compute nodes via the control node. If you do not want Packer's VMs to use this proxy, proxy configuration should be added to the group `${cluster_name}_compute`, not groups `all` or `cluster_compute`.
- TODO: update this. You can't use `-target` (terraform) and `--limit` (ansible) as the `openhpc` role needs all nodes in the play to be able to define `slurm.conf`. If you don't want to configure the entire cluster up-front then alternatives are:
  1. Define/create a smaller cluster in terraform/ansible, create that and build an image, then change the cluster definition to the real one, limiting the ansible play to just `cluster_login`.
  2. Work the other way around:
        - Create the control/login node using TF only (this would need the current inventory to be split up as currently the implicit dependency on `computes` will create those too, even with `-limit`).
        - Build the image.
        - Launch compute nodes w/ TF using that (slurm won't start).
        - Configure control node using `--limit` (will use the local munge key).
