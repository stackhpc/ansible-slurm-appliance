# Alaska cluster

AlaSKA on Arcus

See the main README.md in the repo root for an overview and general install instructions.  Environment-specific instructions here are in matching sections, and are in *addition* to those in the main README unless otherwise noted.

**NB: This README covers both the `prod` and `dev` environments.**

## Installation on deployment host

Additionally, install and initialise terraform:

```shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
cd environments/alaska-prod/terraform
terraform init
```

Download an `openrc.sh` file from Horizon and save as e.g. `~/openrc.sh`.

## Creating a Slurm appliance

This assumes the following already exist:
- A network and subnet named "iris-alaska-prod-internal" to deploy the cluster onto, containing a port "alaska-prod-slurmctl" for the slurm control node.
- A security group "SSH" allowing inbound ssh.
- A security group "NFS" allowing inbound NFS (as the K8s cluster mounts the filesystems exported by the Slurm control node)
- Cinder volumes `alaska-home` (will be mounted as `/home` on control node and subsequently NFS-exported to all nodes) and `alaska-slurmctld-state` (will be mounted as `/mnt/slurmctld` on control node).

0. Create IP addresses:
- Run a command like `openstack floating ip create --description "slurm login-0" CUDN-Internet` as many times as required for each login node.
- Add the resulting addresses to the `address` key in the Terraform `login_nodes` variable (e.g. see `environments/alaska-common/terraform/modules/cluster/variables.tf`).

2. Deploy instances:

```
# activate openstack credentials:
. ~/openrc.sh
cd environments/alaska/terraform

4. Before deploying/modifying the appliance using ansible, export the vault key:

```shell
export ANSIBLE_VAULT_PASSWORD_FILE=~/vault-password.txt
```

