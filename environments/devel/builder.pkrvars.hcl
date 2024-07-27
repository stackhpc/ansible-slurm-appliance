# vars for image build

#hcl
flavor = "slurm_test_compute_lg_amd"
source_image_name = "rocky94_generic_cloud"

# Required network UUIDs for nodes
networks = ["115771bf-beca-482a-8540-8f1011029da1", "7c5451cc-f042-464c-a335-6e2fd120a58d", "420fab25-187a-40f1-aa58-b8bc6913a55a"]

ssh_keypair_name = "vsdeployer"
ssh_private_key_file = "/opt/secure/vsdeployer"
ssh_username = vsadmin
ssh_password = sshtestpass

# 115771bf-beca-482a-8540-8f1011029da1 | control
# 7c5451cc-f042-464c-a335-6e2fd120a58d | compute
# 420fab25-187a-40f1-aa58-b8bc6913a55a | storage
# 3a3c1da0-9b3f-47bc-bccf-e5ea155f37fa | external2