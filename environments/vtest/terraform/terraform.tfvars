compute_types = {
  large: {
    flavor: "compute.c60m240s120e1000"
    image: "rocky8.5_ofed+cuda"
  }
  /* standard: {
    flavor: "compute.c30m120s60e500"
    image: "rocky8.5_ofed+cuda"
  } */
  small: {
    flavor: "compute.c16m64s32e250"
    image: "rocky8.5_ofed+cuda"
  }
  /* tiny: {
    flavor: "compute.c4m16s8e60"
    image: "rocky8.5_ofed+cuda"
  } */
  gpu: {
    flavor: "gpu.c30m120s32e6000"
    image: "rocky8.5_ofed+cuda+driver"
  }
}
#######################################
compute_names = {
# Node-inventory.txt
lg-001: "large"
sm-001: "small"
sm-002: "small"
gpu-001: "gpu"
}
###################################################

login_names = {
  login-1: "gen.c8m16s16"
  admin: "gen.c8m16s16"
}
login_ips = {
  login-1: "10.60.107.241"
  admin: "10.60.107.243"
}
login_image = "rocky8.5_ofed+cuda"
proxy_name = "login-1"

control_image = "rocky8.5_ofed+cuda"
control_flavor = "gen.c16m32s32"
control_ip = "10.60.107.240"

###################################################

cluster_name  = "vtest"
cluster_slurm_name = "vtest"
cluster_availability_zone = "vermilion-tds-az1"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "slurmdeploy"

external_network = "external"
cluster_network = "compute"
cluster_subnet = "compute-subnet"

storage_network = "storage"
storage_subnet = "storage"

control_network = "control"
control_subnet = "control-subnet"

#compute_image = "rocky8.5_ofed+cuda"
#compute_image = "gpu_2021_11_12"
###########  ^^^^^^^^^^^^^^^ CHANGE THIS



#compute_images = {} # allows overrides for specific nodes, by name
compute_images = {}

#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.240 vtest_control_port
#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.241 vtest_login1_port
