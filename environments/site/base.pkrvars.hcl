# base build - will only be used for further builds:
inventory_groups = "doca,freeipa_client,spectrum_scale"

image_name = "openhpc-agr-base"
source_image_name = "openhpc-RL8-260729-0831-035787f3" # for v2.23
volume_size = 20 # GB

flavor = "agr.compute1.8cpu16ram"
image_disk_format = "raw" # will use for further builds
