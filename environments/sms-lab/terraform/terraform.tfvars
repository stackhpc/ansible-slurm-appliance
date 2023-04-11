cluster_name  = "scott-test-cluster"
# compute_names = ["compute-0", "compute-1"]
key_pair      = "slurm-key"
# network       = "stackhpc-ipv4-geneve"
cluster_net = "stackhpc-ipv4-geneve"
cluster_subnet = "stackhpc-ipv4-geneve-subnet"
# compute_image  = "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
# compute_flavor = "general.v1.small"
compute_nodes = {
    compute-0: "small"
    # compute-1: "small"
}
compute_types = {
    small: {
        flavor: "general.v1.small"
        image: "openhpc-230221-1226-raw"
    }
}
control_node = {
    flavor: "general.v1.small"
    image: "openhpc-230221-1226-raw"
}
login_nodes = {
    login-0: {
        flavor: "general.v1.small"
        image: "openhpc-230221-1226-raw"
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