# Demos for OpenHPC on OpenStack

This repo contains ansible playbooks to demonstrate the `stackhpc.openhpc` role and functionality from `stackhpc.slurm_openstack_tools` collection.

All demos use a terraform-deployed cluster with a single control/login node and two compute nodes, all running Centos8 with OpenHPC v2.

# Installation

    git clone  git@github.com:stackhpc/openhpc-tests.git
    cd openhpc-tests
    virtualenv --python $(which python3) venv
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
- `rebuild.yml`: Deploy scripts to enable the reimaging compute nodes controlled by Slurm's `scontrol` command.
- `config-drive.yml` and `main.pkr.hcl`: Packer-based build of compute note images - see separate section below.

For additional details see sections below.

# monitoring.yml

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

# Destroying the cluster

When finished, run:

    terraform destroy
