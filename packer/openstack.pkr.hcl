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
    image_name_version = var.image_name_version == "auto" ? "-${local.timestamp}-${substr(local.git_commit, 0, 8)}" : var.image_name_version
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

# Must supply either source_image_name or source_image_id
variable "source_image_name" {
  type = string
  default = null
  description = "name of source image"
}

variable "source_image" {
  type = string
  default = null
  description = "UUID of source image"
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
  default = true
}

variable "volume_type" {
  type = string
  default = null
}

variable "volume_size" {
  type = number
  default = 15
}

variable "image_disk_format" {
  type = string
  default = "qcow2"
}

variable "metadata" {
  type = map(string)
  default = {}
}

variable "groups" {
  type = string
  description = "Comma-separated list of additional inventory groups (other than 'builder') to add build VM to"
  default = "" # this is 
  # rocky-latest = ["update"]
  # openhpc = ["control", "compute", "login"]
}

variable "image_name" {
  type = string
  description = "Name of image"
  default = "openhpc"
}

variable "image_name_version" {
  type = string
  description = "Suffix for image name giving version. Default of 'auto' appends timestamp + short commit"
  default = "auto"
}

source "openstack" "openhpc" {
  # Build VM:
  flavor = var.flavor
  use_blockstorage_volume = var.use_blockstorage_volume
  volume_type = var.volume_type
  volume_size = var.volume_size
  metadata = var.metadata
  instance_metadata = {
    ansible_init_disable = "true"
  }
  networks = var.networks
  floating_ip_network = var.floating_ip_network
  security_groups = var.security_groups
  
  # Input image:
  source_image = "${var.source_image}"
  source_image_name = "${var.source_image_name}" # NB: must already exist in OpenStack
  
  # SSH:
  ssh_username = var.ssh_username
  ssh_timeout = "20m"
  ssh_private_key_file = var.ssh_private_key_file
  ssh_keypair_name = var.ssh_keypair_name # TODO: doc this
  ssh_bastion_host = var.ssh_bastion_host
  ssh_bastion_username = var.ssh_bastion_username
  ssh_bastion_private_key_file = var.ssh_bastion_private_key_file
  
  # Output image:
  image_disk_format = "qcow2"
  image_visibility = var.image_visibility
  
}

build {

  # latest nightly image:
  # source "source.openstack.openhpc" {
  #   name = "rocky-latest"
  #   image_name = "${source.name}-${var.os_version}"
  # }

  # fat image:
  source "source.openstack.openhpc" {
    image_name = "${var.image_name}${local.image_name_version}"
  }

  # # Extended site-specific image, built on fat image:
  # source "source.openstack.openhpc" {
  #   name = "openhpc-extra"
  #   image_name = "openhpc-${var.extra_build_image_name}-${var.os_version}-${local.timestamp}-${substr(local.git_commit, 0, 8)}"
  # }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/fatimage.yml"
    groups = concat(["builder"], split(",", var.groups))
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    extra_arguments = [
      "--limit", "builder", # prevent running against real nodes, if in inventory!
      "-i", "${var.repo_root}/packer/ansible-inventory.sh",
      "-vv",
      "-e", "@${var.repo_root}/packer/openhpc_extravars.yml", # not overridable by environments
      ]
  }

  post-processor "manifest" {
    output = "${var.manifest_output_path}"
    custom_data  = {
      source = "${source.name}"
    }
  }
}
