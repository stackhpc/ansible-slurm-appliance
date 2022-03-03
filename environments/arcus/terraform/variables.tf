variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_net" {
    type = string
    description = "Name of existing cluster network"
    default = "WCDC-iLab-60"
}

variable "cluster_subnet" {
    type = string
    description = "Name of existing cluster subnet"
    default = "WCDC-iLab-60"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
    default = "slurm-app-ci"
}

variable "control_node" {
    type = map
    description = "Mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
        flavor: "vm.alaska.cpu.general.small"
        image: "RockyLinux-8.5-20211114.2"
    }
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> mapping  {flavor: flavor_name, image: image_name_or_id }"
  default = {
      login-0: {
        flavor: "vm.alaska.cpu.general.small"
        image: "RockyLinux-8.5-20211114.2"
      }
    }
}

variable "compute_types" {
    type = map
    description = "Mapping defining types of compute nodes: key -> (str) name of type, value -> mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
      small: {
          flavor: "vm.alaska.cpu.general.small"
          image: "RockyLinux-8.5-20211114.2"
      }
    }
}

variable "compute_nodes" {
    type = map(string)
    description = "Mapping of compute nodename suffix -> key in compute_types"
    default = {
        compute-0: "small"
        compute-1: "small"
    }
}

variable "cloud_nodes" {
    type = list(string)
    description = "Cloud nodename suffixes to precreate RDMA-capable ports"
    default = [
        "compute-2",
        "compute-3",
    ]
}

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}
