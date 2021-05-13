compute_names = ["hpc-1", "hpc-2", "express-0"]
login_names = ["login-0"] #, "login-1"]
cluster_name  = "protovm" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "centos_at_nrel-deploy-vm"

cluster_network = "nrel2"
cluster_network_cidr = "10.99.0.0/16"
storage_network = "ceph"
storage_subnet = "ceph"
external_network = "external"
external_router = "nrel"

login_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
login_flavor = "general.v1.small"

control_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
control_flavor = "general.v1.small"

compute_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
compute_flavor = "general.v1.small"

# remove this block in the real environment:
cluster_network_type = "geneve"
cluster_network_vnic_type = "normal"
cluster_network_profile = {}
storage_network_vnic_type = "normal"
storage_network_profile = {}
# end of non-default lab config
