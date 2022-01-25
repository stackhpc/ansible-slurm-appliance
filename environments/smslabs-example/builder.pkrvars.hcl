flavor = "general.v1.tiny"
networks = ["c245901d-6b84-4dc4-b02b-eec0fb6122b2"] # stackhpc-ci-geneve
source_image_name = "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
ssh_keypair_name = "slurm-app-ci"
security_groups = ["default", "SSH"]
ssh_bastion_host = "185.45.78.150"
ssh_bastion_username = "slurm-app-ci"
