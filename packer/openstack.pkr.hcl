# Use like:
#   $ PACKER_LOG=1 packer build --on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

# "timestamp" template function replacement:s
locals { timestamp = formatdate("YYMMDD-hhmm", timestamp())}

# Path pointing to root of repository - automatically set by environment variable PKR_VAR_repo_root
variable "repo_root" {
  type = string
}

# Path pointing to environment directory - automatically set by environment variable PKR_VAR_environment_root
variable "environment_root" {
  type = string
}

variable "networks" {
  type = list(string)
}

variable "source_image_name" {
  type = string
}

variable "flavor" {
  type = string
}

variable "ssh_username" {
  type = string
  default = "rocky"
}

variable "ssh_private_key_file" {
  type = string
  default = "~/.ssh/id_rsa"
}

variable "ssh_keypair_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "image_visibility" {
  type = string
  default = "private"
}

variable "ssh_bastion_host" {
  type = string
}

variable "ssh_bastion_username" {
  type = string
}

variable "ssh_bastion_private_key_file" {
  type = string
  default = "~/.ssh/id_rsa"
}

source "openstack" "openhpc" {
  flavor = "${var.flavor}"
  networks = "${var.networks}"
  source_image_name = "${var.source_image_name}" # NB: must already exist in OpenStack
  ssh_username = "${var.ssh_username}"
  ssh_timeout = "20m"
  ssh_private_key_file = "${var.ssh_private_key_file}" # TODO: doc same requirements as for qemu build?
  ssh_keypair_name = "${var.ssh_keypair_name}" # TODO: doc this
  ssh_bastion_host = "${var.ssh_bastion_host}"
  ssh_bastion_username = "${var.ssh_bastion_username}"
  ssh_bastion_private_key_file = "${var.ssh_bastion_private_key_file}"
  security_groups = "${var.security_groups}"
  image_name = "ohpc-${source.name}-${local.timestamp}.qcow2"
  image_visibility = "${var.image_visibility}"
}

# NB: build names, split on "-", are used to determine groups to add build to, so could build for a compute gpu group using e.g. `compute-gpu`.
build {
  source "source.openstack.openhpc" {
    name = "compute"
  }

  source "source.openstack.openhpc" {
    name = "login"
  }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/site.yml"
    host_alias = "packer"
    groups = concat(["builder"], split("-", "${source.name}"))
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    # TODO: use completely separate inventory, which just shares common? This will ensure
    # we don't accidently run anything via delegate_to.
    extra_arguments = ["--limit", "builder", "-i", "./ansible-inventory.sh", "-vv"]
    # TODO: Support vault password
    #ansible_env_vars = ["ANSIBLE_VAULT_PASSWORD_FILE=/home/stack/.kayobe-vault-pass"]
  }

  post-processor "manifest" {
    custom_data  = {
      source = "${source.name}"
    }
  }
}
