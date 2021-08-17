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

2. Deploy instances:

```
# activate openstack credentials:
. ~/openrc.sh
cd environments/alaska/terraform

4. Before deploying/modifying the appliance using ansible then export the vault key:

```shell
export ANSIBLE_VAULT_PASSWORD_FILE=~/vault-password.txt
```

