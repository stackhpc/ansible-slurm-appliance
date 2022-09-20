cluster_name = "slurmdemo"
cluster_net = "your_network_name"
cluster_subnet = "your_subnet_name"
key_pair = "your_keypair_name"
control_node = {
    flavor: "your_flavor_name"
    image: "your_image_name"
}
login_nodes = {
    login-0: {
        flavor: "your_flavor_name"
        image: "your_image_name"
    }
}
compute_types = {
    small: {
        flavor: "your_flavor_name"
        image: "your_image_name"
    }
}
compute_nodes = {
    compute-0: "small"
    compute-1: "small"
}
