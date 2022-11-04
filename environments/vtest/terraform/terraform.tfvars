compute_types = {
  large: {
    flavor: "test.compute.c60m240s8e1k"
    image: "vermilion_rocky86_nodes"
  }
  /* standard: {
    flavor: "compute.c30m120s60e500"
    image: "rocky8.5_ofed+cuda"
  } */
  small: {
    flavor: "test.compute.c4m16s8e60"
    image: "vermilion_rocky86_nodes"
  }
  /* tiny: {
    flavor: "compute.c4m16s8e60"
    image: "Rocky86_login"
  } */
  gpu: {
    flavor: "test.gpu.c30m120s16e5000"
    image: "vermilion_rocky86_nodes"
  }
}
#######################################
compute_names = {
# Node-inventory.txt
lg-001: "large"
lg-002: "large"
sm-001: "small"
sm-002: "small"
gpu-001: "gpu"
gpu-002: "gpu"
}
###################################################

# login_names are are the flavor names to use
login_names = {
  login-1: "test.gen.c8m16s16"
  admin: "test.gen.c8m16s16"
}
login_ips = {
  login-1: "10.60.107.241"
  admin: "10.60.107.243"
}

login_image = "vermilion_rocky86_login"

proxy_name = "login-1"

control_image = "vermilion_rocky86_login"
control_flavor = "test.gen.c8m16s16"
control_ip = "10.60.107.240"

###################################################

cluster_name  = "vtest"
cluster_slurm_name = "vtest"
cluster_availability_zone = "vermilion-az1"

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
