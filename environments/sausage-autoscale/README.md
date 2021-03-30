# Sausage-Autoscale cluster

Dev env for autoscaling on sausagecloud

# Directory structure

## terraform

Contains terraform configuration to deploy infrastructure.

## inventory

Ansible inventory for configuring the infrastructure.

# Setup

In the repo root, run:

    python3 -m venv venv # TODO: do we need system-site-packages?
    . venv/bin/activate
    pip install -U upgrade pip
    pip install requirements.txt
    ansible-galaxy install -r requirements.yml -p ansible/roles
    ansible-galaxy collection install -r requirements.yml -p ansible/collections # don't worry about collections path warning

# Activating the environment

There is a small environment file that you must `source` which defines environment
variables that reference the configuration path. This is so that we can locate
resources relative the environment directory.

    . environments/sausage-autoscale/activate

The pattern we use is that all resources referenced in the inventory
are located in the environment directory containing the inventory that
references them.

# Common configuration

Configuarion is shared by specifiying multiple inventories. We reference the `common`
inventory from `ansible.cfg`, including it before the environment specific
inventory, located at `./inventory`.

Inventories specified later in the list can override values set in the inventories
that appear earlier. This allows you to override values set by the `common` inventory.

Any variables that would be identical for all environments should be defined in the `common` inventory.

# Passwords

Prior to running any other playbooks, you need to define a set of passwords. You can
use the `generate-passwords.yml` playbook to automate this process:

```
cd <repo root>
ansible-playbook ansible/adhoc/generate-passwords.yml # can actually be run from anywhere once environment activated
```

This will output a set of passwords `inventory/group_vars/all/secrets.yml`.
Placing them in the inventory means that they will be defined for all playbooks.

It is recommended to encrypt the contents of this file prior to commiting to git:

```
ansible-vault encrypt inventory/group_vars/all/secrets.yml
```

You will then need to provide a password when running the playbooks e.g:

```
ansible-playbook ../ansible/site.yml --tags grafana --ask-vault-password
```

See the [Ansible vault documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for more details.


# Deploy nodes with Terraform

- Modify the keypair in `main.tf` and ensure the required Centos images are available on OpenStack.
- Activate the virtualenv and create the instances:

      . venv/bin/activate
      cd environments/sausage-autoscale/
      terraform apply

This creates an ansible inventory file `./inventory`.

Note that this terraform deploys instances onto an existing network - for production use you probably want to create a network for the cluster.

# Create and configure cluster with Ansible

Now run one or more playbooks using:

    cd <repo root>
    ansible-playbook ansible/site.yml

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

# FIXME: outdated

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

To achieve best performance for HPL set `openhpc_tests_hpl_NB` in [test.yml](test.yml) to the appropriate the HPL blocksize 'NB' for the compute node processor - for Intel CPUs see [here](https://software.intel.com/content/www/us/en/develop/documentation/mkl-linux-developer-guide/top/intel-math-kernel-library-benchmarks/intel-distribution-for-linpack-benchmark/configuring-parameters.html).

Then run:

    ansible-playbook ../ansible/adhoc/test.yml

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

And run the `test.yml` playbook as described above. If you want to run tests only on a group from this inventory, rather than an entire partition, you can
use ``--limit``

Then running the tests passing this file as extra_vars:

    ansible-playbook ../ansible/test.yml --limit group-in-inventory

# Destroying the cluster

When finished, run:

    terraform destroy --auto-approve
