cluster_name  = "scott-test-cluster"
key_pair      = "slurm-key"
cluster_net = "stackhpc-ipv4-geneve"
cluster_subnet = "stackhpc-ipv4-geneve-subnet"
compute_nodes = {
    compute-0: "small"
    # compute-1: "small"
}
compute_types = {
    small: {
        flavor: "general.v1.small"
        image: "openhpc-230412-1447-raw"
    }
}
control_node = {
    flavor: "general.v1.small"
    image: "openhpc-230412-1447-raw"
}
login_nodes = {
    login-0: {
        flavor: "general.v1.small"
        image: "openhpc-230412-1447-raw"
    }
}

# Reduce volume size a lot for small test cluster
state_volume_size = 10
home_volume_size = 20

login_security_groups = [
    "default",  # allow all in-cluster services
    "SSH",      # access via ssh
    # "HTTPS",    # access OpenOndemand - SMS doesn't have HTTPS security group
]

state_volume_device_path = "/dev/vdb"
home_volume_device_path = "/dev/vdc"