# This terraform configuration uses the site terraform, so that is checked by CI.

terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>3.0.0"
    }
  }
}

variable "environment_root" {
  type        = string
  description = "Path to environment root, automatically set by activate script"
}

variable "cluster_name" {
  type        = string
  description = "Name for cluster, used as prefix for resources - set by environment var in CI"
}

variable "os_version" {
  type        = string
  description = "RL8 or RL9"
  default     = "RL9"
}

variable "cluster_image" {
  description = "single image for all cluster nodes, keyed by os_version - a convenience for CI"
  type        = map(string)
}

# tflint-ignore: terraform_typed_variables
variable "cluster_networks" {}

# tflint-ignore: terraform_typed_variables
variable "vnic_types" {
  default = {}
}

# tflint-ignore: terraform_typed_variables
variable "state_volume_type" {
  default = null
}

# tflint-ignore: terraform_typed_variables
variable "home_volume_type" {
  default = null
}

# tflint-ignore: terraform_typed_variables
variable "control_node_flavor" {}

# tflint-ignore: terraform_typed_variables
variable "other_node_flavor" {}

# tflint-ignore: terraform_typed_variables
variable "volume_backed_instances" {
  default = false
}

data "openstack_images_image_v2" "cluster" {
  name        = var.cluster_image[var.os_version]
  most_recent = true
}

module "cluster" {
  source = "../../site/tofu/"

  cluster_name        = var.cluster_name
  cluster_networks    = var.cluster_networks
  vnic_types          = var.vnic_types
  key_pair            = "slurm-app-ci"
  cluster_image_id    = data.openstack_images_image_v2.cluster.id
  control_node_flavor = var.control_node_flavor

  login = {
    head = {
      nodes  = ["login-0"]
      flavor = var.other_node_flavor
    }
  }
  compute = {
    standard = { # NB: can't call this default!
      nodes                = ["compute-0", "compute-1"]
      flavor               = var.other_node_flavor
      compute_init_enable  = ["compute", "chrony", "etc_hosts", "nfs", "basic_users", "eessi", "tuned", "cacerts", "nhc", "mounts", "journald"]
      ignore_image_changes = true
    }
    # Normally-empty partition for testing:
    extra = {
      nodes = []
      #nodes = ["extra-0", "extra-1"]
      flavor = var.other_node_flavor
    }
  }

  volume_backed_instances = var.volume_backed_instances

  environment_root = var.environment_root
  # Can reduce volume size a lot for short-lived CI clusters:
  state_volume_size = 10
  home_volume_size  = 20

  state_volume_type = var.state_volume_type
  home_volume_type  = var.home_volume_type

}
