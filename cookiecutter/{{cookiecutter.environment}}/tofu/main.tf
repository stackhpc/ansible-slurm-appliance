variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../../tofu/"
    environment_root = var.environment_root

    # cluster_name = foo
}
