variable "environment_root" {
    type = string
    description = "Path to environment root"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "cluster_net" {
    type = string
    description = "Name of existing network to put cluster on"
}

variable "cluster_subnet" {
    type = string
    description = "Name of existing subnet to put cluster on"
}

variable "rdma_net" {
    type = string
    description = "Name of existing network to use for RDMA"
}

variable "slurmctl_rdma_port" {
    type = string
    description = "Name of port on rdma_net for slurm control node - used to export filesystems"
}

variable "slurmctl_port" {
    type = string
    description = "Name of port on cluster_net for slurm control node - used to export filesystems"
}

variable "home_volume" {
    type = string
    description = "Name of existing volume to use for /home"
}

variable "slurmctld_volume" {
    type = string
    description = "Name of existing volume to use for slurmctld state"
}

variable "control_node" {
    type = map
    description = "Mapping {flavor: flavor_name, image: image_name_or_id }"
    default = {
        flavor: "vm.alaska.cpu.nvme.half"
        image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
    }
}

variable "login_nodes" {
  type = map
  description = "Mapping defining login nodes: key -> (str) nodename suffix, value -> mapping  {flavor: flavor_name, image: image_name_or_id }"
  default = {
      login-0: {
        flavor: "vm.alaska.cpu.himem.quarter"
        image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
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
          image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
      }
      full: {
          flavor: "vm.alaska.cpu.general.full"
          image: "Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
      }
    }
}

variable "compute_nodes" {
    type = map(string)
    description = "Mapping of compute nodename suffix -> key in compute_types"
    default = {
        compute-0: "full"
        compute-1: "full"
        compute-2: "full"
        compute-3: "full"
        compute-4: "full"
        compute-5: "full"
        compute-6: "full"
        compute-7: "full"
    }
}

variable "compute_images" {
    type = map(string)
    default = {}
    description = "Mapping to override compute images from compute_types: key ->(str) node name, value -> (str) image name"
}
