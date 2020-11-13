A simple test/demo case for StackHPC's `openhpc` role using VMs on `alaska`.

# Installation

    git clone  git@github.com:stackhpc/openhpc-tests.git
    cd openhpc-tests
    virtualenv --system-site-packages --python $(which python3) venv
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

- Then create the compute VMs e.g. from terraform.

Points to note:
- We want ansible to ssh proxy via the control node for the compute nodes (don't actually need it here as all on one network, but in the general case only the control node will be reachable directly). But we DON'T want packer's "builder" host to get this proxy, so the proxy has to be added to `[${cluster_name}_compute:vars]`, not `[cluster_compute:vars]`.
- You can't use `-target` (terraform) / `--limit` (ansible) as the `openhpc` role needs all nodes in the play to be able to define `slurm.conf`. If you don't want to configure the entire cluster up-front then alternatives are:
  - Define/create a smaller cluster in terraform/ansible, create that and build an image, then change the cluster definition to the real one, limiting the ansible play to just `cluster_login`.
  - Work the other way around:
    - Create the control/login node with TF only (would need some inventory changes as currently the implicit dependency on `computes` will create those too, even with `-limit`)
    - Build the image <-- NO - that needs munge key
    - Launch compute nodes w/ TF using that (slurm won't start)
    - Configure control node using `--limit`
