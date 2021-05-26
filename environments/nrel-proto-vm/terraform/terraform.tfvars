compute_names = {
    hpc-0: "general.v1.small"
    hpc-1: "general.v1.small"
    hpc-2: "general.v1.small"
    hpc-3: "general.v1.small"
    express-0: "general.v1.small"
    express-1: "general.v1.small"
}
login_names = {
    login-0: "general.v1.small"
    login-1: "general.v1.small"
}
proxy_name = "login-0"

cluster_name  = "test" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
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

compute_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"

# remove this block in the real environment:
cluster_network_vnic_type = "normal"
cluster_network_profile = {}
storage_network_vnic_type = "normal"
storage_network_profile = {}
# end of non-default lab config