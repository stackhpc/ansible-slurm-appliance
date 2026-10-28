# std build - used for non-gpu nodes and gpu builds
inventory_groups = "extra_packages,openondemand"

image_name = "openhpc-agr-std"
source_image_name = "openhpc-agr-base-261028-1258-daf4e2c3" # from base build
volume_size = 20 # GB

flavor = "agr.compute1.8cpu16ram"
# image is used for further builds
image_disk_format = "raw"
