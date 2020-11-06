A simple test/demo case for StackHPC's `openhpc` role using VMs on `alaska`.

# Installation

TODO:

# Usage

Activate the venv then:

    terraform apply --autoapprove
    ansible-playbook -i inventory configure.ymls

When finished, run:

    terraform destroy --autoapprove
