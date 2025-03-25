flavor = "ec1.large"
use_blockstorage_volume = false
volume_type = "unencrypted"
volume_size = null
networks = ["909e49e8-6911-473a-bf88-0495ca63853c"] # slurmapp-ci
ssh_keypair_name = "slurm-app-ci"
ssh_private_key_file = "~/.ssh/id_rsa"
security_groups = ["default", "SSH"]
# see environments/.stackhpc/inventory/group_vars/all/bastion.yml:
ssh_bastion_username = "slurm-app-ci"
ssh_bastion_host = "195.114.30.222"
ssh_bastion_private_key_file = "~/.ssh/id_rsa"
