variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "cluster_net" {
    type = string
    description = "Name of existing cluster network"
    default = "hu-lab"
}

variable "cluster_subnet" {
    type = string
    description = "Name of existing cluster subnet"
    default = "hu-lab"
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
        flavor: "en1.small"
        image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
    }
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> mapping  {flavor: flavor_name, image: image_name_or_id }"
  default = {
      login-0: {
        flavor: "en1.small"
        image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
      }
    }
}

variable "compute_types" {
    type = map
    description = "Mapping defining types of compute nodes: key -> (str) name of type, value -> mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
      compute: {
          flavor: "en1.small"
          image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
      }
    }
}

variable "compute_nodes" {
    type = map(string)
    description = "Mapping of compute nodename suffix -> key in compute_types"
    default = {
        compute-0: "compute"
        compute-1: "compute"
    }
}

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}
