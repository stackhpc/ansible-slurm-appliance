# Use like:
#   $ PACKER_LOG=1 packer build --on-error=ask -var-file=$PKR_VAR_environment_root/builder.pkrvars.hcl openstack.pkr.hcl

packer {
  required_plugins {
    git = {
      version = ">= 0.3.2"
      source = "github.com/ethanmdavidson/git"
    }
    openstack = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/openstack"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
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

# Must supply either source_image_name or source_image
variable "source_image_name" {
  type = string
  default = null
}

variable "source_image" {
  type = string
  default = null
}

# Must supply either fatimage_source_image_name or fatimage_source_image
variable "fatimage_source_image_name" {
  type = string
  default = null
}

variable "fatimage_source_image" {
  type = string
  default = null
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
  default = null
}

variable "ssh_keypair_name" {
  type = string
  default = null
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
  default = null
}

variable "ssh_bastion_username" {
  type = string
  default = null
}

variable "ssh_bastion_private_key_file" {
  type = string
  default = "~/.ssh/id_rsa"
}

variable "floating_ip_network" {
  type = string
  default = null
}

variable "manifest_output_path" {
  type = string
  default = "packer-manifest.json"
}

variable "use_blockstorage_volume" {
  type = bool
  default = false
}

variable "volume_size" {
  type = number
  default = null # When not specified use the size of the builder instance root disk
}

variable "image_disk_format" {
  type = string
  default = null # When not specified use the image default
}

variable "metadata" {
  type = map(string)
  default = {}
}

source "openstack" "openhpc" {
  flavor = "${var.flavor}"
  volume_size = "${var.volume_size}"
  use_blockstorage_volume = "${var.use_blockstorage_volume}"
  image_disk_format = "${var.image_disk_format}"
  metadata = "${var.metadata}"
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
    source_image = "${var.source_image}"
    source_image_name = "${var.source_image_name}" # NB: must already exist in OpenStack
    image_name = "ohpc-${source.name}-${local.timestamp}-${substr(local.git_commit, 0, 8)}" # also provides a unique legal instance hostname (in case of parallel packer builds)
  }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/site.yml"
    groups = concat(["builder"], split("-", "${source.name}"))
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    extra_arguments = ["--limit", "builder", "-i", "${var.repo_root}/packer/ansible-inventory.sh", "-vv", "-e", "@${var.repo_root}/packer/${source.name}_extravars.yml"]
  }

  post-processor "manifest" {
    output = "${var.manifest_output_path}"
    custom_data  = {
      source = "${source.name}"
    }
  }
}

# The "fat" image build with all binaries:
build {
  source "source.openstack.openhpc" {
    floating_ip_network = "${var.floating_ip_network}"
    source_image = "${var.fatimage_source_image}"
    source_image_name = "${var.fatimage_source_image_name}" # NB: must already exist in OpenStack
    image_name = "${source.name}-${local.timestamp}-${substr(local.git_commit, 0, 8)}" # similar to name from slurm_image_builder
  }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/fatimage.yml"
    groups = ["builder", "control", "compute", "login"]
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    extra_arguments = ["--limit", "builder", "-i", "${var.repo_root}/packer/ansible-inventory.sh", "-vv", "-e", "@${var.repo_root}/packer/${source.name}_extravars.yml"]
  }

  post-processor "manifest" {
    output = "${var.manifest_output_path}"
    custom_data  = {
      source = "${source.name}"
    }
  }
}
