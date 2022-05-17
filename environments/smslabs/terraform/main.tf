variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources - set by environment var in CI"
}

variable "base_image_name" {
    type = string
    description = "Name of base image for all nodes - set by environment var in CI"
}

module "cluster" {
    source = "../../skeleton/{{cookiecutter.environment}}/terraform/"

    cluster_name = var.cluster_name
    cluster_net = "stackhpc-ci-geneve"
    cluster_subnet = "stackhpc-ci-geneve-subnet"
    nonlogin_security_groups = [
        "default", # as per variable default
        "SSH", # enable ansible, as bastion does not have same default security group as nodes
    ]
    key_pair = "slurm-app-ci"
    control_node = {
        flavor: "general.v1.small"
        image: var.base_image_name
    }
    login_nodes = {
        login-0: {
          flavor: "general.v1.small"
          image: var.base_image_name
        }
    }
    compute_types = {
        small: {
            flavor: "general.v1.small"
            image: var.base_image_name
        }
    }
    compute_nodes = {
        compute-0: "small"
        compute-1: "small"
    }
    
    environment_root = var.environment_root
}
