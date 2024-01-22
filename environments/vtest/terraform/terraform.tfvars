
compute_types = {
  tiny: {
    flavor: "test.compute.c4m16s8e60"
    image: "slurm_rocky93_kbs"
  }
  small: {
    flavor: "test.compute.c8m32s8e60"
    image: "slurm_rocky93_kbs"
  }
  standard: {
    flavor: "test.compute.c30m120s60e5000"
    image: "slurm_rocky93_kbs"
  }
  gpu: {
    flavor: "slurm_test_gpu0"
    image: "slurm_rocky93_kbs"
  }
  gpu3: {
    flavor: "slurm_test_gpu3"
    image: "slurm_rocky93_kbs"
  }
  large: {
    flavor: "slurm_test_compute_lg_amd"
    image: "slurm_rocky93_kbs"
  }
  large_intel: {
    flavor: "slurm_test_compute_lg_intel"
    image: "slurm_rocky93_kbs"
  }
}
# #############################################
# SEE: compute_names.auto.tfvars
#      for node instances that will be created.
# #############################################

#---- login node info ----
# name: flavor
login_names = {
  login-1: "vermilion_util_c8m15"
  admin: "vermilion_util_c8m15"
}
proxy_name = "admin"

# name: IPaddr
login_ips = {
  login-1: "10.60.107.241"
  admin: "10.60.107.243"
}

login_image = "slurm_rocky93_kbs"
login_flavor = "vermilion_util_c8m15"


#---- CONTROL node info ----
control_image = "slurm_rocky93_kbs"
control_flavor = "vermilion_util_c8m15"
control_ip = "10.60.107.240"

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

##compute_image = "rocky8.5_ofed+cuda"
##compute_image = "gpu_2021_11_12"

###########  ^^^^^^^^^^^^^^^ CHANGE THIS
##compute_images = {} # allows overrides for specific nodes, by name
compute_images = {}
