# Alaska cluster

AlaSKA on Arcus

See the main README.md in the repo root for an overview and general install instructions.  Environment-specific instructions here are in matching sections, and are in *addition* to those in the main README unless otherwise noted.

## Installation on deployment host

Additionally, install and initialise terraform:

```shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
cd environments/alaska/terraform
terraform init
```

Download an `openrc.sh` file from Horizon and save as e.g. `~/openrc.sh`.

## Creating a Slurm appliance

This assumes that a network named "iris-alaska-prod-internal" exists to deploy the cluster onto.

0. Create IP addresses:
- Run a command like `openstack floating ip create --description "slurm login-0" CUDN-Internet` as many times as required for each login node.
- Add the resulting addresses to the `address` key in the Terraform `login_nodes` variable (e.g. see `environments/alaska/terraform/variables.tf`).

2. Deploy instances:

```
# activate openstack credentials:
. ~/openrc.sh
cd environments/alaska/terraform

4. Before deploying/modifying the appliance using ansible, export the vault key:

```shell
export ANSIBLE_VAULT_PASSWORD_FILE=~/vault-password.txt
```

