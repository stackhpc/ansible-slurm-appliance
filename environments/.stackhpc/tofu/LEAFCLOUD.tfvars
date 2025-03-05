cluster_networks = [
    {
        network = "slurmapp-ci"
        subnet = "slurmapp-ci"
    }
]
control_node_flavor = "en1.medium" # min 6GB RAM
other_node_flavor = "en1.xsmall"
state_volume_type = "unencrypted"
home_volume_type = "unencrypted"
