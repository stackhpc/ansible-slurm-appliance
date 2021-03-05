# Packer-based image build

This workflow uses Packer to build an image for a compute node. Key aspects of this are:
- QEMU and KVM are used to create a VM using a Centos8 base image.
- Packer runs the same ansible we use to create the cluster normally, but with this VM in a "builder" ansible group which is also in the "compute" group.
- As Packer cannot (necessary) contact the cluster login node to get the munge key, the key is injected into the image from a local copy.
- A "configless" slurm mode is used so that the image does not need to contain the slurm config, and hence the image can be used for any number of nodes.
- The ansible playbooks are configured so that the slurm, munge and NFS services are enabled but not started.

Steps:

- Ensure hardware virtualisation is enabled:

      egrep 'vmx|svm' /proc/cpuinfo

- Follow the standard installation instructions in the main README.

- Install packer and qemu-kvm:

      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum -y install packer
      #sudo yum -y install qemu # not available on Centos8, not sure we need it?
      sudo yum -y install qemu-kvm

- Activate the venv and the relevant environment.
- TODO: UPDATE THIS: Create a cluster using terraform and `slurm-simple.yml` as above (`slurm-db.yml` should also work, but the playbook used is hardcoded in `main.pkr.hcl`).
- Ensure you have a public/private keypair as `~/.ssh/id_rsa[.pub]`.
- Create a config drive which sets this public key for the `centos` user, so that Packer can login to the VM:

    ansible-playbook packer/config-drive.yml # creates packer/config-drive.iso

- Build an image (using that config drive), output to `build/`:

        mkfifo /tmp/qemu-serial.in /tmp/qemu-serial.out
        cd packer
        PACKER_LOG=1 packer build main.pkr.hcl
        # or during development:
        PACKER_LOG=1 packer build --on-error=ask main.pkr.hcl

- To login to the VM over ssh look for the following line in the Packer output:

        Executing /usr/libexec/qemu-kvm: ...  "-netdev", "user,id=user.0,hostfwd=tcp::2922-:22", ... 

  which specifies the ssh port forwarding Packer is using to log-in to the VM, so in this case login using:

        ssh -p 2922 centos@127.0.0.1

- You can watch the console output from the VM startup in another terminal using:

        cat /tmp/qemu-serial.out

- Upload the image to Openstack:

        openstack image create --file build/*.qcow2 --disk-format qcow2 $(basename build/*.qcow2)

- Then recreate the compute VMs with the new image e.g. by changing the compute image name in `main.tf` and rerunning terraform. **NB:** You may need to restart `slurmctld` if the nodes come up and then go down again.

Some more subtle points to note if developing code based off this:
- In general, we should assume that ansible needs to ssh proxy to the compute nodes via the control node (not actually the case in these demos as everything is on one network). However we **don't** want packer's "builder" host to use this proxy, so the proxy has to be added to the group `[${cluster_name}_compute:vars]`, not `[cluster_compute:vars]`.
- You can't use `-target` (terraform) and `--limit` (ansible) as the `openhpc` role needs all nodes in the play to be able to define `slurm.conf`. If you don't want to configure the entire cluster up-front then alternatives are:
  1. Define/create a smaller cluster in terraform/ansible, create that and build an image, then change the cluster definition to the real one, limiting the ansible play to just `cluster_login`.
  2. Work the other way around:
        - Create the control/login node using TF only (this would need the current inventory to be split up as currently the implicit dependency on `computes` will create those too, even with `-limit`).
        - Build the image.
        - Launch compute nodes w/ TF using that (slurm won't start).
        - Configure control node using `--limit` (will use the local munge key).
