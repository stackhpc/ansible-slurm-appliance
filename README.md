# Demos for OpenHPC on OpenStack

This repo contains ansible playbooks to demonstrate the `stackhpc.openhpc` role and functionality from `stackhpc.slurm_openstack_tools` collection.

All demos use a terraform-deployed cluster with a single control/login node and two compute nodes, all running Centos8 with OpenHPC v2.

NB: Working DNS is a requirement.

# Installation

    git clone  git@github.com:stackhpc/openhpc-demo.git
    cd openhpc-demo
    sudo yum install -y virtualenv
    virtualenv --system-site-packages --python $(which python3) venv
    . venv/bin/activate
    pip install -U pip
    pip install -U setuptools
    pip install -r requirements.txt
    ansible-galaxy install -r requirements.yml # TODO: fix openhpc role once pushed to galaxy
    yum install terraform
    terraform init

NB: For development of roles/collections you may want to use this alternative to `ansible-galaxy ...`:

    mkdir roles
    mkdir collections
    ansible-galaxy role install -r requirements.yml -p roles
    ansible-galaxy collection install -r requirements.yml -p collections


# Deploy nodes with Terraform

- Modify the variables in `main.tfvars` as required and ensure the required Centos images are available on OpenStack.
- Activate the virtualenv and create the instances:

      . venv/bin/activate
      terraform apply -var-file="main.tfvars"

This creates an ansible inventory file `./inventory`.

Note that this terraform deploys instances onto an existing network - for production use you probably want to create a network for the cluster.

# Create and configure cluster with Ansible

Now run one or more playbooks using:

    ansible-playbook -i inventory <playbook.yml>

Available playbooks are:

- `slurm-simple.yml`: A basic slurm cluster.
- `slurm-db.yml`: The basic slurm cluster plus slurmdbd backed by mariadb on the login/control node, which provides more detailed accounting.
- `monitoring-simple.yml`: Add basic monitoring, with prometheus and grafana on the login/control node providing graphical dashboards (over http) showing cpu/network/memory/etc usage for each cluster node. Run `slurm-simple.yml` first.
- `monitoring-db.yml`: Basic monitoring plus statistics and dashboards for Slurm jobs . Run `slurm-db.yml` first.
- `rebuild.yml`: Deploy scripts to enable the reimaging compute nodes controlled by Slurm's `scontrol` command. Run `slurm-simple.yml` or `slurm-db.yml` first.
- `config-drive.yml` and `main.pkr.hcl`: Packer-based build of compute note images - see separate section below.
- `test.yml`: Run a set of MPI-based tests on the cluster. Run `slurm-simple.yml` or `slurm-db.yml` first.

For additional details see sections below.

# monitoring-simple.yml

Run this using:

    ansible-playbook -i inventory -e grafana_password=<password> monitoring.yml

This provides:
- grafana at `http://<login_ip>:3000` - username `grafana`, password as set above
- prometheus at `http://<login_ip>:9090`

NB: if grafana's yum repos are down you will see `Errors during downloading metadata for repository 'grafana' ...`. You can work around this using:

    ssh centos@<login_ip>
    sudo rm -rf /etc/yum.repos.d/grafana.repo
    wget https://dl.grafana.com/oss/release/grafana-7.3.1-1.x86_64.rpm
    sudo yum install grafana-7.3.1-1.x86_64.rpm
    exit
    ansible-playbook -i inventory monitoring.yml -e grafana_password=<password> --skip-tags grafana_install

# rebuild.yml

Enable the compute nodes of a Slurm-based OpenHPC cluster on Openstack to be reimaged from Slurm.

For full details including the Slurm commmands to use see the [role's README](https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/blob/main/roles/rebuild/README.md)

Ensure you have `~/.config/openstack/clouds.yaml` defining authentication for a a single Openstack cloud (see above README to change location).

Then run:

    ansible-playbook -i inventory rebuild.yml

Note this does not rebuild the nodes, only deploys the tools to do so.

# test.yml

This runs MPI-based tests on the cluster:
- `pingpong`: Runs Intel MPI Benchmark's IMB-MPI1 pingpong between a pair of (scheduler-selected) nodes. Reports zero-size message latency and maximum bandwidth.
- `pingmatrix`: Runs a similar pingpong test but between all pairs of nodes. Reports zero-size message latency & maximum bandwidth.
- `hpl-solo`: Runs HPL **separately** on all nodes, using 80% of memory, reporting Gflops on each node.

These names can be used as tags to run only a subset of tests. For full details see the [role's README](https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/blob/main/roles/test/README.md).

Note these are intended as post-deployment tests for a cluster to which you have root access - they are **not** intended for use on a system running production jobs:
- Test directories are created within `openhpc_tests_rootdir` (here `/mnt/nfs/ohcp-tests`) which must be on a shared filesystem (read/write from login/control and compute nodes)
- Generally, packages are only installed on the control/login node, and `/opt` is exported via NFS to the compute nodes.
- The exception is the `slurm-libpmi-ohpc` package (required for `srun` with Intel MPI) which is installed on all nodes.
- Cleanup is not perfect: `/opt` is unmounted on compute nodes and un-exported from the control/login node but the NFS service is left running and `slurm-libpmi-ohpc` is not uninstalled, as both these cases
  may be valid for the cluster anyway.

To achieve best performance for HPL set `openhpc_tests_hpl_NB` in [test.yml](test.yml) to the appropriate the HPL blocksize 'NB' for the compute node processor - for Intel CPUs see [here](https://software.intel.com/content/www/us/en/develop/documentation/mkl-linux-developer-guide/top/intel-math-kernel-library-benchmarks/intel-distribution-for-linpack-benchmark/configuring-parameters.html).

Then run:

    ansible-playbook -i inventory test.yml

Results will be reported in the ansible stdout - the pingmatrix test also writes an html results file onto the ansible host.

Note that you can still use the `test.yml` playbook even if the terraform/ansible in this repo wasn't used to deploy the cluster - as long as it's running OpenHPC v2. Simply create an appropriate `inventory` file, e.g:

    [all:vars]
    ansible_user=centos

    [cluster:children]
    cluster_login
    cluster_compute

    [cluster_login]
    slurm-control

    [cluster_compute]
    cpu-h21a5-u3-svn2
    cpu-h21a5-u3-svn4
    ...

And run the `test.yml` playbook as described above. If you want to run tests only on a group from this inventory, rather than an entire partition, you can set the `openhpc_tests_nodes` role variable by firstly creating a file eg. `nodes.yml` which references an inventory group:

    openhpc_tests_nodes: "{{ groups['cluster_compute'] | join(',') }}"

Then running the tests passing this file as extra_vars:

    ansible-playbook -i inventory test.yml -e @nodes.yml


# Packer-based image build

This workflow uses Packer to build an image for a compute node then deploys the cluster using this image. Key aspects of this are:
- QEMU and KVM are used to create a VM using a Centos8 base image.
- Packer runs the same ansible we use to create the cluster normally, but with this VM in a "builder" ansible group which is also in the "compute" group.
- As Packer cannot (necessary) contact the cluster login node to get the munge key, the key is injected into the image from a local copy.
- A "configless" slurm mode is used (the default for the `slurm-*.yml` examples above) so that the image does not need to contain the slurm config, and hence the image can be used for any number of nodes.
- The ansible playbooks are configured so that the slurm, munge and NFS services are enabled but not started.

Steps:

- Install packer and qemu-kvm:

      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum -y install packer
      sudo yum -y install qemu
      sudo yum -y install qemu-kvm

- Activate the venv.
- Ensure `stackhpc.openhpc` role is on branch `packer`. # FIXME: once merged
- Ensure you have a public/private keypair as `~/.ssh/id_rsa[.pub]`.
- Create a config drive which sets this public key for the `centos` user, so that Packer can login to the VM:

    ansible-playbook config-drive.yml # creates config-drive.iso

- Build a compute image (using that config drive), output to `build/`:

        mkfifo /tmp/qemu-serial.in /tmp/qemu-serial.out
        PACKER_LOG=1 packer build main.pkr.hcl # may also find `--on-error=ask` useful during development

  This runs `slurm-image.yml` which is a modified version of `slurm-simple.yml`. It will output:
  - The image file in `build/testohpc-compute.qcow2`
  - A generated munge key in `/builder/etc/munge/munge.key`
    
- You can watch the image startup in another terminal using:

        cat /tmp/qemu-serial.out

- Upload the image to Openstack:

        openstack image create --file build/*.qcow2 --disk-format qcow2 $(basename build/*.qcow2)

- Deploy a control node (using a base image) and 2x compute nodes (using this image):

        terraform apply -var-file="image.tfvars"

  Note that as the compute nodes can't contact the control node at this point they will enter the DOWN state.

- Configure the login node:

        ansible-playbook -i inventory slurm-image.yml

  This uses the inventory generated by terraform to define the slurm configuration, as usual. Note that `--limit testohpc-login-0` cannot be used as this configuration relies on ansible collecting facts from at least one
  compute node to define CPU information for slurm. However all tasks will be a no-op on the compute nodes, except for starting slurmd (as this will have failed when the node booted).
  
`TODO: check this is true:` This code also supports the alternative approach of:
- Creating a login/control node first with zero compute nodes
- Creating a compute image and deploying nodes with that image
- Rerunning ansible to rewrite the slurm configuration.

In this case you will need to "manually" restart the daemons (TODO: describe play for this) to use the new configuration.

If developing code based off this note that ansible will probably generally need to ssh proxy to the compute nodes via the control node (not actually the case in these demos as everything is on one network). However we **don't** want packer's "builder" host to use this proxy, so the proxy has to be added to the group `[${cluster_name}_compute:vars]`, not `[cluster_compute:vars]`.

# Destroying the cluster

When finished, run:

    terraform destroy --auto-approve

