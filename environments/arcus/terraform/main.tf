variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources - set by environment var in CI"
}

variable "create_nodes" {
    description = "Whether to create nodes (servers) or just ports and other infra"
    type = bool # can't use bool as want to pass from command-line
    default = true
}

module "cluster" {
    source = "../../skeleton/{{cookiecutter.environment}}/terraform/"

    cluster_name = var.cluster_name
    cluster_net = "WCDC-iLab-60"
    cluster_subnet = "WCDC-iLab-60"
    vnic_type = "direct"
    key_pair = "slurm-app-ci"
    control_node = {
        flavor: "vm.alaska.cpu.general.small"
        image: "openhpc-221027-1557.qcow2"
    }
    login_nodes = {
        login-0: {
            flavor: "vm.alaska.cpu.general.small"
            image: "openhpc-221027-1557.qcow2"
        }
    }
    compute_types = {
        small: {
            flavor: "vm.alaska.cpu.general.small"
            image: "openhpc-221027-1557.qcow2"
        }
        extra: {
            flavor: "vm.alaska.cpu.general.small"
            image: "openhpc-221027-1557.qcow2"
        }
    }
    compute_nodes = {
        compute-0: "small"
        compute-1: "small"
        compute-2: "extra"
        compute-3: "extra"
    }
    create_nodes = var.create_nodes
    
    environment_root = var.environment_root
}
