cluster_networks = [
  {
    network = "slurmapp-ci"
    subnet  = "slurmapp-ci"
  }
]
control_node_flavor = "ec1.medium" # small ran out of memory, medium gets down to ~100Mi mem free on deployment
other_node_flavor   = "en1.xsmall"
gpu_node_flavor     = "eg1.a30x1.V8-32" # Looks like all leafcloud flavors should be supported by open drivers
state_volume_type   = "unencrypted"
home_volume_type    = "unencrypted"
