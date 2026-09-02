# base build - will only be used for further builds:
inventory_groups = "doca,freeipa_client,spectrum_scale"

image_name = "openhpc-agr-base"
source_image_name = "openhpc-RL8-260818-0723-3f645271" # upstream StackHPC release image for v2.24.0
volume_size = 20 # GB

flavor = "agr.compute1.8cpu16ram"
# image is used for further builds
image_disk_format = "raw"
