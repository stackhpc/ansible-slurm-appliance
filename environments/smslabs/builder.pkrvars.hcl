flavor = "general.v1.small"
networks = ["c245901d-6b84-4dc4-b02b-eec0fb6122b2"] # stackhpc-ci-geneve
source_image_name = "openhpc-220526-1354.qcow2"
ssh_keypair_name = "slurm-app-ci"
security_groups = ["default", "SSH"]
ssh_bastion_host = "185.45.78.150"
ssh_bastion_username = "slurm-app-ci"
use_blockstorage_volume = true
