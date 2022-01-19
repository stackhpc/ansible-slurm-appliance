variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_net" {
    type = string
    description = "Name of existing cluster network"
    default = "stackhpc-ipv4-geneve"
}

variable "cluster_subnet" {
    type = string
    description = "Name of existing cluster subnet"
    default = "stackhpc-ipv4-geneve-subnet"
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
        flavor: "general.v1.tiny"
        image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
    }
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> mapping  {flavor: flavor_name, image: image_name_or_id }"
  default = {
      login-0: {
        flavor: "general.v1.tiny"
        image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
      }
    }
}

variable "compute_types" {
    type = map
    description = "Mapping defining types of compute nodes: key -> (str) name of type, value -> mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
      small: {
          flavor: "general.v1.tiny"
          image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
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

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}
