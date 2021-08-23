variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "control_node" {
    type = map
    description = "Mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
        flavor: "vm.alaska.cpu.nvme.half"
        image: "CentOS8-2105"
    }
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> mapping  {flavor: flavor_name, image: image_name_or_id }"
  default = {
      login-0: {
        flavor: "vm.alaska.cpu.general.small"
        image: "CentOS8-2105"
        address: "128.232.222.246"
      }
    }
}

variable "compute_types" {
    type = map
    description = "Mapping defining types of compute nodes: key -> (str) name of type, value -> mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
      small: {
          flavor: "vm.alaska.cpu.general.small"
          image: "CentOS8-2105"
      }
    }
}

variable "compute_nodes" {
    type = map(string)
    description = "Mapping of compute nodename suffix -> key in compute_types"
    default = {
        compute-0: "small"
        compute-1: "small"
        compute-2: "small"
        compute-3: "small"
    }
}

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}
