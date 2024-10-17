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

variable "os_version" {
  type = string
  description = "'RL8' or 'RL9' with default source_image_* mappings"
  default = "RL9"
}

# Must supply either source_image_name or source_image_id
variable "source_image_name" {
  type = string
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
  type = map(number)
  default = {
    # fat image builds, GB:
    rocky-latest = 15
    rocky-latest-cuda = 30
    openhpc = 15
    openhpc-cuda = 30
  }
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
  type = map(list(string))
  description = "Additional inventory groups (other than 'builder') to add build VM to, keyed by source name"
  default = {
    # fat image builds:
    rocky-latest = ["update", "ofed"]
    rocky-latest-cuda = ["update", "ofed", "cuda"]
    openhpc = ["control", "compute", "login"]
    openhpc-cuda = ["control", "compute", "login"]
  }
}

source "openstack" "openhpc" {
  # Build VM:
  flavor = var.flavor
  use_blockstorage_volume = var.use_blockstorage_volume
  volume_type = var.volume_type
  volume_size = var.volume_size[source.name]
  metadata = var.metadata
  instance_metadata = {ansible_init_disable = "true"}
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
  source "source.openstack.openhpc" {
    name = "rocky-latest"
    image_name = "${source.name}-${var.os_version}"
  }

  # latest nightly cuda image:
  source "source.openstack.openhpc" {
    name = "rocky-latest-cuda"
    image_name = "${source.name}-${var.os_version}"
  }

  # OFED fat image:
  source "source.openstack.openhpc" {
    name = "openhpc"
    image_name = "${source.name}-${var.os_version}-${local.timestamp}-${substr(local.git_commit, 0, 8)}"
  }

  # CUDA fat image:
  source "source.openstack.openhpc" {
    name = "openhpc-cuda"
    image_name = "${source.name}-${var.os_version}-${local.timestamp}-${substr(local.git_commit, 0, 8)}"
  }

  # Extended site-specific image, built on fat image:
  source "source.openstack.openhpc" {
    name = "openhpc-extra"
    image_name = "${source.name}-${var.os_version}-${local.timestamp}-${substr(local.git_commit, 0, 8)}"
  }

  provisioner "ansible" {
    playbook_file = "${var.repo_root}/ansible/fatimage.yml"
    groups = concat(["builder"], var.groups[source.name])
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
