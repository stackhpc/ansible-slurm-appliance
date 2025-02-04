compute_types = {
  gpu: {
    flavor: "slurm_test_gpu0"
    image: "openhpc-250204-1517-8795b1ab"
  }
  gpu3: {
    flavor: "slurm_test_gpu3"
    image: "openhpc-250204-1517-8795b1ab"
  }
  gpu5: {
    flavor: "slurm_test_gpu5"
    image: "openhpc-250204-1517-8795b1ab"
  }
  large: {
    flavor: "slurm_test_compute_lg"
    image: "openhpc-250204-1517-8795b1ab"
  }
  large_intel: {
    flavor: "slurm_test_compute_lg_intel"
    image: "openhpc-250204-1517-8795b1ab"
  }
}


# #############################################
# SEE: compute_names.auto.tfvars
#      for node instances that will be created.
# #############################################

#---- login node info ----
login_image = "openhpc-250204-1517-8795b1ab"
login_flavor = "vermilion_slurm_login_c8m15"

login_names = {
  vtlogin-1: "vermilion_slurm_login_c8m15"
  vtadmin: "vermilion_slurm_login_c8m15"
}
# name: IPaddr
login_ips = {
  vtlogin-1: "10.60.105.71"
  vtadmin: "10.60.105.73"
}

# CONTROL node info
control_flavor = "slurm_admin_c8m12s1d50"
control_ip     = "10.60.105.70"
control_image = "openhpc-250204-1517-8795b1ab"

proxy_name = "vtadmin"
# The `admin` node is like a login node,
# but access is limited for admin-type worlflows

###################################################

cluster_name  = "vtest"
cluster_slurm_name = "vtest"
cluster_availability_zone = "esif"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

#key_pair = "slurmdeploy"
key_pair = "vsdeployer"

external_network = "external"
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
