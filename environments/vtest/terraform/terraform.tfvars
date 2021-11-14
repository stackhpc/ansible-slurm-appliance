compute_types = {
  large: {
    flavor: "compute.c60m240s120e1000"
    image: "CentOS84_ldap_v0.1"
  }
  standard: {
    flavor: "compute.c30m120s60e500"
    image: "CentOS84_ldap_v0.1"
  }
  small: {
    flavor: "compute.c16m64s32e250"
    image: "CentOS84_ldap_v0.1"
  }
  tiny: {
    flavor: "compute.c4m16s8e60"
    image: "CentOS84_ldap_v0.1"
  }
  gpu: {
    flavor: "gpu.c30m120s32e6000"
    image: "CentOS8.4_ofed+cuda_kbs"
  }
}

login_names = {
  login-1: "gen.c8m16s16"
}

login_ips = {
  login-1: "10.60.105.223"
}
###########  ^^^^^^^^^^^^^^^ CHANGE THIS

login_image = "c83_login.v2"

proxy_name = "login-1"

cluster_name  = "vtest"
cluster_slurm_name = "vermilion"
# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

key_pair = "slurmdeploy"

external_network = "external"
cluster_network = "compute"
cluster_subnet = "compute-subnet"

storage_network = "storage"
storage_subnet = "storage"

control_network = "control"
control_subnet = "control-subnet"

control_image = "CentOS8.3"
control_flavor = "gen.c16m32s32"
control_ip = "10.60.107.3"
###########  ^^^^^^^^^^^^^^^ CHANGE THIS

compute_images = {} # allows overrides for specific nodes, by name

compute_names = {
# Node-inventory.txt
std-0001: "standard"
sm-0001: "small"
sm-0002: "small"
gpu-0001: "gpu"
}

