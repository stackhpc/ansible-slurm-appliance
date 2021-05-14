compute_names = {
    hpc-0: "compute.c16m60s32e250"
    hpc-1: "compute.c16m60s32e250"
    hpc-2: "compute.c16m60s32e250
    hpc-3: "compute.c16m60s32e250"
    express-0: "compute.c16m60s32e250"
    express-1: "compute.c16m60s32e250"
}
login_names = {
    login-0: "gen.c8m15"
    login-1: "gen.c8m15"
}
proxy_name: "login-0"

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

control_image = "CentOS8.3"
control_flavor = "gen.c16m30"

compute_image = "CentOS8.3"
