compute_names = ["compute-0", "compute-1"]
cluster_name  = "nrel" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "sb5"
cluster_network = "public-109"

login_image = "CentOS8.2-cloud"
login_flavor = "baremetal"

control_image = "CentOS8.2-cloud"
control_flavor = "baremetal"

compute_image = "CentOS8.2-cloud"
compute_flavor = "baremetal"
