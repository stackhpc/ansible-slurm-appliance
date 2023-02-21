# Use like:
#   $ PACKER_LOG=1 packer build --on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

packer {
  required_plugins {
    git = {
      version = ">= 0.3.2"
      source = "github.com/ethanmdavidson/git"
    }
  }
}

data "git-commit" "cwd-head" { }

locals {
    git_commit = data.git-commit.cwd-head.hash
    timestamp = formatdate("YYMMDD-hhmm", timestamp())
}

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

variable "fatimage_source_image_name" {
  type = string
  default = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64.qcow2"
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
  default = []
}

variable "image_visibility" {
  type = string
  default = "private"
}

variable "ssh_bastion_host" {
  type = string
  default = ""
}

variable "ssh_bastion_username" {
  type = string
  default = ""
}

variable "ssh_bastion_private_key_file" {
  type = string
  default = "~/.ssh/id_rsa"
}

source "openstack" "openhpc" {
  flavor = "${var.flavor}"
  networks = "${var.networks}"
  ssh_username = "${var.ssh_username}"
  ssh_timeout = "20m"
  ssh_private_key_file = "${var.ssh_private_key_file}" # TODO: doc same requirements as for qemu build?
  ssh_keypair_name = "${var.ssh_keypair_name}" # TODO: doc this
  ssh_bastion_host = "${var.ssh_bastion_host}"
  ssh_bastion_username = "${var.ssh_bastion_username}"
  ssh_bastion_private_key_file = "${var.ssh_bastion_private_key_file}"
  security_groups = "${var.security_groups}"
  image_visibility = "${var.image_visibility}"
}

# NB: build names, split on "-", are used to determine groups to add build to, so could build for a compute gpu group using e.g. `compute-gpu`.
build {
  source "source.openstack.openhpc" {
    name = "compute"
    source_image_name = "${var.source_image_name}" # NB: must already exist in OpenStack
    image_name = "ohpc-${source.name}-${local.timestamp}-${substr(local.git_commit, 0, 8)}.qcow2" # also provides a unique legal instance hostname (in case of parallel packer builds)
  }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/site.yml"
    groups = concat(["builder"], split("-", "${source.name}"))
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    extra_arguments = ["--limit", "builder", "-i", "${var.repo_root}/packer/ansible-inventory.sh", "-vv", "-e", "@${var.repo_root}/packer/${source.name}_extravars.yml"]
  }

  post-processor "manifest" {
    custom_data  = {
      source = "${source.name}"
    }
  }
}

# The "fat" image build with all binaries:
build {
  source "source.openstack.openhpc" {
    source_image_name = "${var.fatimage_source_image_name}" # NB: must already exist in OpenStack
    image_name = "${source.name}-${local.timestamp}-${substr(local.git_commit, 0, 8)}.qcow2" # similar to name from slurm_image_builder
  }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/fatimage.yml"
    groups = ["builder", "control", "compute", "login"]
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    extra_arguments = ["--limit", "builder", "-i", "${var.repo_root}/packer/ansible-inventory.sh", "-vv", "-e", "@${var.repo_root}/packer/${source.name}_extravars.yml"]
  }

  post-processor "manifest" {
    custom_data  = {
      source = "${source.name}"
    }
  }
}
