# compute node build, currently non-cuda
# run using:

# cd packer/
# PACKER_LOG=1 /usr/bin/packer build \
#   -only=openstack.openhpc \
#   -on-error=ask \
#   -var-file=../environments/vtest/builder.pkrvars.hcl \
#   openstack.pkr.hcl

flavor = "slurm_test_compute_lg"
networks = ["7c5451cc-f042-464c-a335-6e2fd120a58d"] # compute network
source_image_name = "slurm_hpc_vs_base_r94_20240609"
#ssh_username = rocky
ssh_private_key_file = /home/rocky/.ssh/vsdeployer
ssh_keypair_name = "vsdeployer"

groups = {
    openhpc = ["update", "compute"] # TODO: add cuda when ready
}
