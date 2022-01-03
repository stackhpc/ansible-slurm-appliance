compute_types = {
  large: {
    flavor: "compute.c60m240s120e1000"
    image: "CentOS8.4_ofed5.3-1+cuda11.4"
  }
  standard: {
    flavor: "compute.c30m120s60e500"
    image: "CentOS8.4_ofed5.3-1+cuda11.4"
  }
  small: {
    flavor: "compute.c16m64s32e250"
    image: "CentOS8.4_ofed5.3-1+cuda11.4"
  }
  tiny: {
    flavor: "compute.c4m16s8e60"
    image: "CentOS8.4_ofed5.3-1+cuda11.4"
  }
  gpu: {
    flavor: "gpu.c30m120s32e6000"
    image: "gpu_2021_11_12"
  }
}
#######################################
compute_names = {
# Node-inventory.txt
std-001: "standard"
std-002: "standard"
sm-001: "small"
sm-002: "small"
gpu-001: "gpu"
}
###################################################
login_names = {
  login1: "gen.c8m16s16"
}
login_ips = {
  login1: "10.60.107.241"
}
login_image = "c83_login.v2"
proxy_name = "login1"
###################################################

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

control_image = "CentOS84_ldap_v0.1"
control_flavor = "gen.c16m32s32"
control_ip = "10.60.107.240"

#compute_image = "CentOS8.4_ofed5.3-1+cuda11.4"
#compute_image = "gpu_2021_11_12"
###########  ^^^^^^^^^^^^^^^ CHANGE THIS



#compute_images = {} # allows overrides for specific nodes, by name
compute_images = {}

#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.240 vtest_control_port
#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.241 vtest_login1_port
