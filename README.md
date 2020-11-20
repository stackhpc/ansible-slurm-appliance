# Demos for OpenHPC on OpenStack

This repo contains ansible playbooks to demonstrate the `stackhpc.openhpc` role and functionality from `stackhpc.slurm_openstack_tools` collection.

All demos use a terraform-deployed cluster with a single control/login node and two compute nodes, all running Centos8 with OpenHPC v2.

# Installation

    git clone  git@github.com:stackhpc/openhpc-tests.git
    cd openhpc-tests
    virtualenv --system-site-packages --python $(which python3) venv
    . venv/bin/activate
    pip install -U pip
    pip install -U setuptools
    pip install -r requirements.txt
    ansible-galaxy install -r requirements.yml -p roles # FIXME - needs git nfs role too currently
    cd roles
    git clone git@github.com:stackhpc/ansible-role-openhpc.git # FIXME
    cd ..
    yum install terraform
    terraform init

    # TODO: need to add collection in here too.

# Deploy nodes with Terraform

- Modify the keypair in `main.tf` and ensure the required Centos images are available on OpenStack.
- Activate the virtualenv and create the instances:

      . venv/bin/activate
      terraform apply

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

For full details see the [role's README](https://github.com/stackhpc/ansible_collection_slurm_openstack_tools/blob/main/roles/test/README.md).

First set `openhpc_tests_hpl_NB` in [test.yml](test.yml) to the appropriate the HPL blocksize 'NB' for the compute node processor - for Intel CPUs see [here](https://software.intel.com/content/www/us/en/develop/documentation/mkl-linux-developer-guide/top/intel-math-kernel-library-benchmarks/intel-distribution-for-linpack-benchmark/configuring-parameters.html).

Then run:

    ansible-playbook -i inventory test.yml

Results will be reported in the ansible stdout - the pingmatrix test also writes an html results file onto the ansible host.

# Packer-based image build

Currently WIP!

First:
- Ensure `stackhpc.openhpc` role is using `packer` branch.
- Ensure terraform `main.tf` configured to use centos8 cloud image for login node.
- Configure `slurm-simple.yml` to use `openhpc_slurm_configless: true`
- Run terraform and ansible to create and configure all nodes (as above).*
- Retrieve the generated munge key from the control/login node and save in this directory as `munge.key`.
- Build an image:

        mkfifo /tmp/qemu-serial.in /tmp/qemu-serial.out
        . venv/bin/activate
        ansible-playbook config-drive.yml
        PACKER_LOG=1 packer build main.pkr.hcl # may also find `--on-error=ask` useful
    
- In another terminal, watch the image startup:

        cat /tmp/qemu-serial.out

- Upload the image:

        openstack image create --file build/*.qcow2 --disk-format qcow2 $(basename build/*.qcow2)

- Then recreate the compute VMs with the new image e.g. using terraform. **NB:** You may need to restart `slurmctld` if the nodes come up and then go down again.

Points to note:
- We want ansible to ssh proxy via the control node for the compute nodes (don't actually need it here as all on one network, but in the general case only the control node will be reachable directly). But we DON'T want packer's "builder" host to get this proxy, so the proxy has to be added to `[${cluster_name}_compute:vars]`, not `[cluster_compute:vars]`.
- You can't use `-target` (terraform) / `--limit` (ansible) as the `openhpc` role needs all nodes in the play to be able to define `slurm.conf`. If you don't want to configure the entire cluster up-front then alternatives are:
  - Define/create a smaller cluster in terraform/ansible, create that and build an image, then change the cluster definition to the real one, limiting the ansible play to just `cluster_login`.
  - Work the other way around:
    - Define a local munge key.
    - Create the control/login node using TF only (would need the current inventory to be split up as currently the implicit dependency on `computes` will create those too, even with `-limit`).
    - Build the image.
    - Launch compute nodes w/ TF using that (slurm won't start).
    - Configure control node using `--limit` (will use the local munge key).

# Destroying the cluster

When finished, run:

    terraform destroy --auto-approve

