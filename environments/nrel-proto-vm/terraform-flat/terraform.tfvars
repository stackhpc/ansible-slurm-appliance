compute_names = ["hpc-0", "hpc-1", "hpc-2", "hpc-3", "express-0", "express-1"]
login_names = ["login-0"]
cluster_name  = "protovm" # don't put dashes (creates invalid ansible group names) or underscores (creates hostnames which get mangled) in this
key_pair = "centos_at_nrel-deploy-vm"
cluster_network = "nrel"

login_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
login_flavor = "general.v1.small"
login_availability_zone = "nova:kef1p-phyhyp0002.novalocal"

control_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
control_flavor = "general.v1.small"
control_availability_zone = "nova:kef1p-phyhyp0002.novalocal"

compute_image = "CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64"
compute_flavor = "general.v1.small"
compute_availability_zone = "nova:kef1p-phyhyp0004.novalocal"