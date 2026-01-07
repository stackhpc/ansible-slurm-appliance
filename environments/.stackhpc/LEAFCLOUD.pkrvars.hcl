flavor = "ec1.large"
volume_type = "unencrypted"
networks = ["909e49e8-6911-473a-bf88-0495ca63853c"] # slurmapp-ci
ssh_keypair_name = "slurm-app-ci"
security_groups = ["default", "SSH"]
# see environments/.stackhpc/inventory/group_vars/all/bastion.yml:
ssh_bastion_username = "slurm-app-ci"
ssh_bastion_host = "45.135.59.32"
ssh_bastion_agent_auth = true
ssh_agent_auth = true
