variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources"
}

variable "key_pair" {
    type = string
    description = "Name of an existing keypair in OpenStack"
}

variable "control_flavor" {
    type = string
    description = "Name of instance flavor for control node"
    default = "baremetal"
}

variable "control_image" {
    type = string
    description = "Name of image for compute node"
}


