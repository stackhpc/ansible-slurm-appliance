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

# Image build

WIP: based on lightly-modified `https://github.com/mrsipan/packer-centos-8` - doesn't currently run ansible, uses root user w/ hardcoded password.

    mkfifo /tmp/qemu-serial.in /tmp/qemu-serial.out
    PACKER_LOG=1 packer build main.json

In another terminal, watch the output installation:

    cat /tmp/qemu-serial.out
    