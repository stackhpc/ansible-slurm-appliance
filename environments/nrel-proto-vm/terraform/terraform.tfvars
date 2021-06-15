compute_types = {
    small: {
        flavor: "general.v1.small"
        image: "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
    }
    tiny: {
        flavor: "general.v1.tiny"
        image: "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
    }
}

compute_names = {
    sm-001: "small"
    sm-002: "small"
    ty-001: "tiny"
    ty-002: "tiny"
}

compute_images = { # allows overrides for specific nodes, by name
    sm-002: "CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64"
} 

login_names = {
    login-0: "general.v1.small"
}
proxy_name = "login-0"

cluster_name  = "test" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
cluster_slurm_name = "vermilion" # as above
key_pair = "centos_at_nrel-deploy-vm"

cluster_network = "compute"
cluster_subnet = "compute-subnet"
storage_network = "storage"
storage_subnet = "storage"
external_network = "external"
control_network = "nrel"
control_subnet = "nrel-subnet"

login_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"

control_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
control_flavor = "general.v1.small"

# remove this block in the real environment:
cluster_network_vnic_type = "normal"
cluster_network_profile = {}
storage_network_vnic_type = "normal"
storage_network_profile = {}
# end of non-default lab config