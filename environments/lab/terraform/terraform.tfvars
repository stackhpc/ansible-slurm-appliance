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
    flavor: "vm.ska.cpu.general.small"
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

login_ips = {
  login-1: "10.60.105.223"
}
#

login_image = "Rocky-9-GenericCloud-Base-9.3-20231113.0.x86_64.qcow2"
login_flavor = "vm.ska.cpu.general.small"


control_image = "Rocky-9-GenericCloud-Base-9.3-20231113.0.x86_64.qcow2"
control_flavor = "vm.ska.cpu.general.small"

control_ip = "10.60.106.230"

proxy_name = "login-1"

#######################################

cluster_name  = "vslab"
cluster_slurm_name = "vermilion"
cluster_availability_zone = "nova"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

key_pair = "slurm-app-ci"

external_network = "CUDN-Internet"
cluster_network = "lab-compute" # tf-deployed
cluster_subnet = "lab-compute"

storage_network = "lab-storage"  # tf-deployed
storage_subnet = "lab-storage"

control_network = "portal-internal"
control_subnet = "portal-internal"


###########  ^^^^^^^^^^^^^^^ CHANGE THIS
#compute_images = {} # allows overrides for specific nodes, by name
compute_images = {}

# reserve ports for the above:
#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.240 vtest_control_port
#openstack port create --network external --fixed-ip subnet=external,ip-address=10.60.107.241 vtest_login1_port
