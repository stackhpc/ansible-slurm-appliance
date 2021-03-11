compute_names = ["hpc-0", "hpc-1", "hpc-2", "hpc-3", "express-0", "express-1"]
login_names = ["login-0", "login-1"]
cluster_name  = "proto" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "centos_at_deploy"
cluster_network = "public-109"

login_image = "CentOS8.3-cloud"
login_flavor = "baremetal"

control_image = "CentOS8.3-cloud"
control_flavor = "baremetal"

compute_image = "CentOS8.3-cloud"
compute_flavor = "baremetal"
