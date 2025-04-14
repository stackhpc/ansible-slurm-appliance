flavor = "hpc.v2.16cpu.128ram"                           # VM flavor to use for builder VMs
networks = ["d21d2d5c-58dc-43a8-954c-8ebd4da7e198"]   # List of network UUIDs to attach the VM to
source_image_name = "openhpc-RL9-250312-1435-7e5c051d"   # Name of image to create VM with, i.e. starting image
inventory_groups = "doca,cuda"            # Additional inventory groups to add build VM to
volume_size= "30"            # Larger volume to fit DOCA install
image_disk_format = "raw"
