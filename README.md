A simple test/demo case for StackHPC's `openhpc` role using VMs on `alaska`.

# Installation

    git clone  git@github.com:stackhpc/openhpc-tests.git
    cd openhpc-tests
    virtualenv --python $(which python3) venv
    . venv/bin/activate
    pip install -U pip
    pip install -U setuptools
    pip install -r requirements.txt
    ansible-galaxy install -r requirements.yml -p roles
    cd roles
    git clone git@github.com:stackhpc/ansible-role-openhpc.git # for development
    cd ..
    yum install terraform
    terraform init
    
# Usage

Activate the virtualenv:

    . venv/bin/activate

Create the instances (on an existing network):

    terraform apply --autoapprove

Configure a slurm cluster:

    ansible-playbook -i inventory slurm-simple.yml

Add monitoring with grafana on port 3000 and prometheus on port 9090 of login node (see `monitoring.yml` for grafana credentials):

    ansible-playbook -i inventory monitoring.yml


When finished, run:

    terraform destroy --autoapprove
