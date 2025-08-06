variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../site/tofu/"
    environment_root = var.environment_root

    # Environment specific variables
    # cluster_name = "foo"
}
