A simple test/demo case for StackHPC's `openhpc` role using VMs on `alaska`.

# Installation

    . venv/bin/activate
    ansible-galaxy install -r requirements.yml -p roles

# Usage

Activate the virtualenv:

    . venv/bin/activate

Create the instances (on an existing network):

    terraform apply --autoapprove

Configure a slurm cluster:

    ansible-playbook -i inventory configure.ymls

Add monitoring with grafana on port 3000 and prometheus on port 9090 of login node (see `monitoring.yml` for grafana credentials):

    ansible-playbook -i inventory monitoring.ymls


When finished, run:

    terraform destroy --autoapprove
