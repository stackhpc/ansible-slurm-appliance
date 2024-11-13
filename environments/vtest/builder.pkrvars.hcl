hcl
flavor = "slurm_test_gpu0"
networks = ["control", "compute", "storage"]
source_image_name = "slurm_hpc_vs_base_r94_20240609"
source_image = "ef2d6424-730a-4e50-9bbb-cd3160b6b7f5"  #uuid

ssh_username = rocky
ssh_private_key_file = /home/rocky/.ssh/vsdeployer
ssh_keypair_name = vsdeployer

floating_ip_network = notexternal

