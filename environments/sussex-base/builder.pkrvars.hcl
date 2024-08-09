flavor = "general.v1.4cpu.8gb"
image_disk_format = "qcow2" # default comes out as raw for some reason
use_blockstorage_volume = true # required to set image image_disk_format
volume_size = 25 # GB. df in image showed ~18GB used

# Specify image by id to match environment/sussex-base/variables.tf:
source_image = {
    RL9 = "8b4482a0-208f-4889-abac-46656fd5fb62" # openhpc-ofed-RL9-240712-1425-6830f97b-raid-v1: v1.150+RAID
}

# Have to set this when using source_image to override default:
source_image_name = {
    RL8 = null
    RL9 = null
}

# Add only CUDA during build:
groups = {
    openhpc-extra = ["cuda"]
}

# Configure networking & ssh access to be similar to cluster:
networks = ["2127b46a-9cca-4f40-b030-e54cc73cf354"] # slurm - want direct outbound internet
ssh_keypair_name = "slurm-deploy-v2"
ssh_private_key_file = "~/.ssh/slurm-deploy-v2"
