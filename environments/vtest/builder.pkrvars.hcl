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
source_image_name = "vslurmbasesrcimage20241117"
#ssh_username = rocky
ssh_private_key_file = "/home/rocky/.ssh/vsdeployer"
ssh_keypair_name = "vsdeployer"

groups = {
    openhpc = ["update", "compute"] # TODO: add cuda when ready
}
