compute_types = {
  tiny: {
    flavor: "test.compute.c4m16s8e60"
    image: "openhpc-ofed-RL9-240712-1425"
  }
  small: {
    flavor: "test.compute.c8m32s8e60"
    image: "openhpc-ofed-RL9-240712-1425"
  }
  standard: {
    flavor: "test.compute.c30m120s60e5000"
    image: "openhpc-ofed-RL9-240712-1425"
  }
  gpu: {
    flavor: "slurm_test_gpu0"
    image: "openhpc-ofed-RL9-240712-1425"
  }
  gpu3: {
    flavor: "slurm_test_gpu3"
    image: "openhpc-ofed-RL9-240712-1425"
  }
  large: {
    flavor: "slurm_test_compute_lg_amd"
    image: "openhpc-ofed-RL9-240712-1425"
  }
  large_intel: {
    flavor: "slurm_test_compute_lg_intel"
    image: "openhpc-ofed-RL9-240712-1425"
  }
}

# #############################################
# SEE: compute_names.auto.tfvars
#      for node instances that will be created.
# #############################################

#---- login node info ----
login_image = "openhpc-ofed-RL9-240712-1425"
login_flavor = "vermilion_util_c8m15"

proxy_name = "devadmin"

# The `admin` node is like a login node, 
# but access is limited for admin-type worlflows

login_names = {
  devlogin-1: "vermilion_util_c8m15"
  devadmin: "vermilion_util_c8m15"
}
# name: IPaddr
login_ips = {
  devlogin-1: "10.60.105.71"
  devadmin: "10.60.105.73"
}

#---- CONTROL node info ----

control_image = "openhpc-ofed-RL9-240712-1425"
control_ip = "10.60.105.70"
control_flavor = "vermilion_util_c8m15"

###################################################

cluster_name  = "devel"
cluster_slurm_name = "devel"
cluster_availability_zone = "esif"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

#key_pair = "slurmdeploy"
key_pair = "vsdeployer"

external_network = "external2"
cluster_network = "compute"
cluster_subnet = "compute-subnet"

storage_network = "storage"
storage_subnet = "storage-subnet"

control_network = "control"
control_subnet = "control-subnet"

## compute_image = "rocky8.5_ofed+cuda"
## compute_image = "gpu_2021_11_12"
## ^^^^^^^^^^^^^^^ CHANGE THIS?

compute_images = {} # allows overrides for specific nodes, by name
