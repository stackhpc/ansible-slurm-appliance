cluster_networks = [
    # {
    #     network = "stackhpc-ipv4-geneve"
    #     subnet = "stackhpc-ipv4-geneve-subnet"
    # }
    {
        network = "steveb-isolated"
        subnet = "steveb-isolated"
    }
]
control_node_flavor = "general.v1.small"
other_node_flavor = "general.v1.small"


# stackhpc-ipv4-geneve-subnet:  172.16.0.0 - 172.16.1.255
# stackhpc-ipv4-vlan-subnet     192.168.48.0 - 192.168.48.255
# steveb-isolated 192.168.99.0 - 192.168.99.255