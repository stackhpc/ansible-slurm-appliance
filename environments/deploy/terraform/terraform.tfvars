compute_names = {
  lg-0001: "compute.c60m240s120e1000"
  lg-0002: "compute.c60m240s120e1000"

  std-0001: "compute.c30m120s60e500"
  std-0002: "compute.c30m120s60e500"

  sm-0001: "compute.c16m64s32e250"
  sm-0002: "compute.c16m64s32e250"

  t-0001: "compute.c4m16s8e60"
  t-0002: "compute.c4m16s8e60"

  gpu-0001: "gpu.c30m120s32e6000"

}
login_names = {
  login-1: "gen.c8m16s16"
  login-2: "gen.c8m16s16"
}

proxy_name = "login-1"

cluster_name  = "vs" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "slurmdeploy"

external_network = "external"
cluster_network = "compute"
cluster_subnet = "compute-subnet"

storage_network = "storage"
storage_subnet = "storage"

control_network = "control"
control_subnet = "control-subnet"

login_image = "CentOS8.3_login"
control_image = "CentOS8.3"
compute_image = "CentOS8.3"

control_flavor = "gen.c16m32s32"

