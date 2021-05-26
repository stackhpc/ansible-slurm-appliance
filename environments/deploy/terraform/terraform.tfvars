compute_types = {
  large: {
    flavor: "compute.c60m240s120e1000"
    image: "CentOS8.3"
  }
  standard: {
    flavor: "compute.c30m120s60e500"
    image: "CentOS8.3"
  }
  small: {
    flavor: "compute.c16m64s32e250"
    image: "CentOS8.3"
  }
  tiny: {
    flavor: "compute.c4m16s8e60"
    image: "CentOS8.3"
  }
  gpu: {
    flavor: "gpu.c30m120s32e6000"
    image: "CentOS8.3"
  }
}

compute_names = {
  lg-0001: "large"
  lg-0002: "large"

  std-0001: "standard"
  std-0002: "standard"

  sm-0001: "small"
  sm-0002: "small"

  t-0001: "tiny"
  t-0002: "tiny"

  gpu-0001: "gpu"

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
compute_images = {} # allows overrides for specific nodes, by name

control_flavor = "gen.c16m32s32"

