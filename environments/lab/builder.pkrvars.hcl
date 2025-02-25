# compute node build, currently non-cuda
# run using:

# cd packer/
# PACKER_LOG=1 /usr/bin/packer build \
#   -only=openstack.openhpc \
#   -on-error=ask \
#   -var-file=../environments/vtest/builder.pkrvars.hcl \
#   openstack.pkr.hcl

flavor = "en1.medium"
networks = ["a28bd8de-2729-434b-a009-732143d17ce5"]
source_image_name = "Rocky-9-GenericCloud-Base-9.5-20241118.0.x86_64.qcow2"
#ssh_username = rocky
ssh_private_key_file = "/home/rocky/.ssh/vsdeployer"
ssh_keypair_name = "vsdeployer"
volume_type = "unencrypted"

inventory_groups = "compute,control,login,update"
