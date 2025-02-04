flavor = "slurm_test_compute_lg"
networks = ["3a3c1da0-9b3f-47bc-bccf-e5ea155f37fa"] # external network
source_image_name = "vslurm_20241118"
#ssh_username = rocky
ssh_private_key_file = "/home/rocky/.ssh/vsdeployer"
ssh_keypair_name = "vsdeployer"

inventory_groups = "compute,control,login,update"
image_name = "slcompute"
