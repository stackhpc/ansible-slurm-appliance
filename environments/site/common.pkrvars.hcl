# common vars for all builds

# Use the same keypair as the clusters to make debugging easier:
ssh_keypair_name = "rocky_bastion_v2"
# Set PKR_VAR_ssh_private_key_file set to path to private key

# Use existing bastion
ssh_bastion_host = "slurm-bastion.eri.agresearch.co.nz"
ssh_bastion_username = "rocky"
# Set PKR_VAR_ssh_bastion_private_key_file to path to private key

networks = [
    "2058e8ba-b3f6-4eb3-862f-3eb13d05dfd7",  # nesi-hpc-baremetal-vlan112
]
