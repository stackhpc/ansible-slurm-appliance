compute_types = {
  large: {
    flavor: "test.compute.c60m240s8e1k"
    image: "slurm_rocky93_rc"
  }
  standard: {
    flavor: "test.compute.c30m120s60e5000"
    image: "slurm_rocky93_rc"
  }
  small: {
    flavor: "test.compute.c8m32s8e60"
    image: "slurm_rocky93_rc"
  }
  tiny: {
    flavor: "test.compute.c4m16s8e60"
    image: "slurm_rocky93_rc"
  }
  gpu: {
    flavor: "slurm_test_gpu_gpu0"
    image: "slurm_rocky93_rc"
  }
  gpu3: {
    flavor: "slurm_test_gpu_gpu3"
    image: "slurm_rocky93_rc"
  }
}
#######################################
compute_names = {
# Node-inventory.txt
vtlg-001: "large"
vtlg-002: "large"
vtsm-001: "small"
vtsm-002: "small"
vtt-001: "small"
vtt-002: "small"
vtgpu3-001: "gpu3"
vtgpu3-002: "gpu3"
}
###################################################

#---- login node info ----
# name: flavor
login_names = {
  vtest-login-1: "slurm_test_service"
  vtest-admin: "slurm_test_service"
}

# name: IPaddr
login_ips = {
  vtest-login-1: "10.60.107.241"
  vttest-admin: "10.60.107.243"
}

login_image = "slurm_rocky93_rc"
login_flavor = "slurm_test_service"

#---- /login ----

proxy_name = "vtest-admin"

#---- CONTROL node info ----
control_image = "slurm_rocky93_rc"
control_flavor = "slurm_test_service"
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

##compute_image = "rocky8.5_ofed+cuda"
##compute_image = "gpu_2021_11_12"

###########  ^^^^^^^^^^^^^^^ CHANGE THIS
##compute_images = {} # allows overrides for specific nodes, by name
compute_images = {}
