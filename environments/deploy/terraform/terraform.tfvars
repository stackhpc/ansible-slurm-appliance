compute_names = ["hpc-0", "hpc-1", "hpc-2", "hpc-3", "express-0", "express-1"]
login_names = ["login-0"] #, "login-1"]
cluster_name  = "ntest" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "slurmdeploy"

cluster_network = "compute"
cluster_subnet = "compute-subnet"
storage_network = "storage"
storage_subnet = "storage"
external_network = "external"
control_network = "control"
control_subnet = "control-subnet"

login_image = "CentOS8.3"
login_flavor = "gen.c8m15"

control_image = "CentOS8.3"
control_flavor = "gen.c16m30"

compute_image = "CentOS8.3"
compute_flavor = "compute.c16m60s32e250"

# remove this block in the real environment:
// cluster_network_type = "geneve"
// cluster_network_vnic_type = "normal"
// cluster_network_profile = {}
#storage_network_vnic_type = "normal"
#storage_network_profile = {}
# end of non-default lab config
