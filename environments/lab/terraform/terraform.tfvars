compute_types = {
    small: {
        flavor: "general.v1.small"
        image: "Rocky-8-GenericCloud-8.6.20220702.0.x86_64"
    }
    tiny: {
        flavor: "general.v1.tiny"
        image: "Rocky-8-GenericCloud-8.6.20220702.0.x86_64"
    }
}

compute_names = {
    sm-001: "small"
    sm-002: "small"
    ty-001: "tiny"
    ty-002: "tiny"
}

login_names = {
    login-0: "general.v1.tiny"
    admin: "general.v1.tiny"
}
#

login_image = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64"

proxy_name = "" # need to set something but its unused in lab

control_image = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64"
control_flavor = "general.v1.tiny"

#######################################

cluster_name  = "nrel"
cluster_slurm_name = "nrel" # as above
cluster_availability_zone = "nova"

# don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this

key_pair = "slurm-app-ci"

external_network = "external"
cluster_network = "nrel-compute"
cluster_subnet = "nrel-compute"

storage_network = "nrel-storage"
storage_subnet = "nrel-storage"

control_network = "stackhpc-ipv4-geneve"
control_subnet = "stackhpc-ipv4-geneve-subnet"


# remove this block in the real environment:
cluster_network_vnic_type = "normal"
cluster_network_profile = {}
storage_network_vnic_type = "normal"
storage_network_profile = {}
# end of non-default lab config
