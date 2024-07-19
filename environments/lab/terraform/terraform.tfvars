compute_types = {
  large: {
    flavor: "compute.c60m240s120e1000"
    image: "vs_rocky86_20221231"
  }
  standard: {
    flavor: "compute.c30m120s60e500"
    image: "vs_rocky86_20221231"
  }
  small: {
    flavor: "en1.xsmall"
    image: "Rocky-9-GenericCloud-Base-9.3-20231113.0.x86_64.qcow2"
  }
  tiny: {
    flavor: "compute.c4m16s8e60"
    image: "vs_rocky86_20221231"
  }
  gpu: {
    flavor: "gpu.c30m120s32e6000"
    image: "vs_rocky86_20221231"
  }
}

compute_names = {
# Node-inventory.txt


sm-0001: "small"
sm-0002: "small"


}


##########################################

login_names = {
  login-1: "gen.c8m16s16"
}
#

login_ips = {} # Don't use FIPs for lab but need to define for symlinked variables.tf
#

login_image = "Rocky-9-GenericCloud-Base-9.3-20231113.0.x86_64.qcow2"
login_flavor = "en1.xsmall"


control_image = "Rocky-9-GenericCloud-Base-9.3-20231113.0.x86_64.qcow2"
control_flavor = "ec1.medium"

control_ip = "" # Don't use FIPs for lab but need to define for symlinked variables.tf

proxy_name = "login-1"

#######################################

cluster_name  = "vslab"
cluster_slurm_name = "vermilion"
cluster_availability_zone = "europe-nl-ams1"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

key_pair = "slurm-app-ci"

external_network = "external"
cluster_network = "nrel-lab-compute"
cluster_subnet = "nrel-lab-compute" # 10.90.0.0/24

storage_network = "nrel-lab-storage"
storage_subnet = "nrel-lab-storage" # 10.91.0.0/24

control_network = "stackhpc-dev"
control_subnet = "stackhpc-dev"
compute_images = {} # allows overrides for specific nodes, by name
