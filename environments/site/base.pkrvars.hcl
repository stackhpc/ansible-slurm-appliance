# base build - will only be used for further builds:
inventory_groups = "doca,freeipa_client,spectrum_scale,extra_packages"

image_name = "openhpc-agr-base"
source_image_name = "openhpc-RL8-260818-0723-3f645271" # for v2.24.0
volume_size = 20 # GB

flavor = "agr.compute1.8cpu16ram"
# image is used for further builds and directly for both BM and VM nodes
image_disk_format = "raw"
