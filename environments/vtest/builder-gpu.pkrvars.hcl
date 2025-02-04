# compute node build, currently non-cuda
# run using:

# cd packer/
# PACKER_LOG=1 /usr/bin/packer build \
#   -only=openstack.openhpc \
#   -on-error=ask \
#   -var-file=../environments/vtest/builder.pkrvars.hcl \
#   openstack.pkr.hcl

flavor = "slurm_test_compute_lg"
networks = ["3a3c1da0-9b3f-47bc-bccf-e5ea155f37fa"] # external network
source_image_name = "vslurm_20241118"
#ssh_username = rocky
ssh_private_key_file = "/home/rocky/.ssh/vsdeployer"
ssh_keypair_name = "vsdeployer"

volume_size = 30 # 30 GB volume for doca/cuda build
inventory_groups = "compute,control,login,update,doca,cuda"
image_name = "slgpu"

