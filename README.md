# Demos for OpenHPC on OpenStack

This repo contains ansible playbooks to demonstrate the `stackhpc.openhpc` role and functionality from `stackhpc.slurm_openstack_tools` collection.

All demos use a terraform-deployed cluster with a single control/login node and two compute nodes.

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

|Playbook | Previous plays required	| Notes |
|-------- |	----------------------- | ----- |
| slurm-simple.yml	| |
| slurm-db.yml | |
| monitoring.yml | slurm-simple.yml or slurm-db.yml	| Needs Wills changes for slurm-stats merged |
| slurm-stats.yml |	monitoring.yml | Rename slurm-stats to just "stats"? |
| rebuild.yml |	slurm-simple.yml or slurm-db.yml | |
| config-drive.yml | slurm-simple.yml or slurm-db.yml | |
| main.pkr.hcl*	|config-drive.yml | |

    


Configure a slurm cluster:

    ansible-playbook -i inventory slurm-simple.yml

Add monitoring:

    ansible-playbook -i inventory -e grafana_password=<password> monitoring.yml

now you can access:
    - grafana: `http://<login_ip>:3000` - username `grafana`, password as set above
    - prometheus: `http://<login_ip>:9090`

NB: if grafana's yum repos are down you will see `Errors during downloading metadata for repository 'grafana' ...`. You can work around this using:

    ssh centos@<login_ip>
    sudo rm -rf /etc/yum.repos.d/grafana.repo
    wget https://dl.grafana.com/oss/release/grafana-7.3.1-1.x86_64.rpm
    sudo yum install grafana-7.3.1-1.x86_64.rpm
    exit
    ansible-playbook -i inventory monitoring.yml -e grafana_password=<password> --skip-tags grafana_install

When finished, run:

    terraform destroy --auto-approve
