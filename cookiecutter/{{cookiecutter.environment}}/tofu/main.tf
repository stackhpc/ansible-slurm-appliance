# tflint-ignore: terraform_required_version

variable "environment_root" {
  type        = string
  description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
  source           = "../../site/tofu/"
  environment_root = var.environment_root

  # Environment specific variables
  # Note that some of the variables below may need to be moved to the site environment
  # defaults e.g cluster_networks should be in site if your staging and prod
  # environments use the same networks
  cluster_name        = null
  cluster_image_id    = null
  control_node_flavor = null
  cluster_networks    = null
  key_pair            = null
  login               = null
  compute             = null
}
