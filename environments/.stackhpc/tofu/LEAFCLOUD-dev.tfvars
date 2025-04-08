cluster_networks = [
    {
        network = "stackhpc-dev"
        subnet = "stackhpc-dev"
    }
]
control_node_flavor = "ec1.medium" # small ran out of memory, medium gets down to ~100Mi mem free on deployment
other_node_flavor = "en1.xsmall"
state_volume_type = "unencrypted"
home_volume_type = "unencrypted"
