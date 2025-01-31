compute_types = {
  stackhpc: {
    flavor: "en1.small"
    image_id: "7b05f133-a11b-4042-96c1-423ae1366055"
  }
}


# #############################################
# SEE: compute_names.auto.tfvars
#      for node instances that will be created.
# #############################################

#---- login node info ----
login_image = "openhpc-250130-1524-bc08e6e2"
login_flavor = "en1.small"

login_names = {
  vtlogin-1: "vermilion_slurm_login_c8m15"
  vtadmin: "vermilion_slurm_login_c8m15"
}

# CONTROL node info
control_flavor = "en1.medium"
control_image = "openhpc-250130-1524-bc08e6e2"

proxy_name = "vtadmin"
# The `admin` node is like a login node,
# but access is limited for admin-type worlflows

###################################################

cluster_name  = "lab"
cluster_slurm_name = "lab"
cluster_availability_zone = "europe-nl-ams1"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

key_pair = "vsdeployer"

external_network = "external"
cluster_network = "cluster"
cluster_subnet = "cluster"

storage_network = "storage"
storage_subnet = "storage"

control_network = "control"
control_subnet = "control"

cluster_network_vnic_type = "normal"
storage_network_vnic_type = "normal"

storage_network_profile = {}
cluster_network_profile = {}

compute_images = {} # allows overrides for specific nodes, by name
