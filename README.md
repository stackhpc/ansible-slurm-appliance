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

# Passwords

Prior to running any other playbooks, you need to define a set of passwords. You can
use the `generate-passwords.yml` playbook to automate this process:

```
ansible-playbook generate-passwords.yml
```

This will output a set of passwords <`repository root>/inventory/group_vars/all/passwords.yml`.
Placing them in the inventory means that they will be defined for all playbooks.

It is recommended to encrypt the contents of this file prior to commiting to git:

```
ansible-vault encrypt inventory/group_vars/all/passwords.yml
```

You will then need to provide a password when running the playbooks e.g:

```
ansible-playbook monitoring-db.yml --tags grafana --ask-vault-password
```

See the [Ansible vault documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for more details.

# Usage

Modify the keypair in `main.tf`.

Activate the virtualenv:

    . venv/bin/activate

Create the instances (on an existing network):

    terraform apply --auto-approve

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
