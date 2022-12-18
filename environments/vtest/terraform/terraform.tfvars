compute_types = {
  large: {
    flavor: "test.compute.c60m240s8e1k"
    image: "TEST_Rocky86_login"
  }
  /* standard: {
    flavor: "compute.c30m120s60e5000"
    image: "rocky-221117-1304"
  } */
  small: {
    flavor: "test.compute.c8m32s8e60"
    image: "TEST_Rocky86_login"
  }
  /* tiny: {
    flavor: "compute.c4m16s8e60"
    image: "rocky-221117-1304"
  } */
  gpu: {
    flavor: "test.gpu.c30m120s16e5000"
    image: "TEST_Rocky86_login"
  }
}
#######################################
compute_names = {
# Node-inventory.txt
vlg-001: "large"
vsm-001: "small"
vgpu-001: "gpu"
}
###################################################

login_names = {
  vtlogin-1: "test.gen.c8m16s16"
  vtadmin: "test.gen.c8m16s16"
}
login_ips = {
  vtlogin-1: "10.60.107.241"
  vtadmin: "10.60.107.243"
}

login_image = "TEST_Rocky86_login"

proxy_name = "vtlogin-1"

control_image = "TEST_Rocky86_login"
control_flavor = "test.gen.c8m16s16"
control_ip = "10.60.107.240"

###################################################

cluster_name  = "vtest"
cluster_slurm_name = "vtest"
cluster_availability_zone = "esif"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

key_pair = "slurmdeploy"

external_network = "external"
cluster_network = "compute"
cluster_subnet = "compute-subnet"

storage_network = "storage"
storage_subnet = "storage-subnet"

control_network = "control"
control_subnet = "control-subnet"

#compute_image = "rocky8.5_ofed+cuda"
#compute_image = "gpu_2021_11_12"
###########  ^^^^^^^^^^^^^^^ CHANGE THIS
#compute_images = {} # allows overrides for specific nodes, by name
compute_images = {}

#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.240 vtest_control_port
#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.241 vtest_login1_port
