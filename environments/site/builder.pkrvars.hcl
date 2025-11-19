flavor = "std.v1.16cpu.128ram"                          # VM flavor to use for builder VMs
networks = ["0d3bf7a7-269a-4c36-8c83-6150306e7e06"]     # List of network UUIDs to attach the VM to
source_image_name = "openhpc-250910-1710-f605b7d8"      # Name of image to create VM with, i.e. starting image
security_groups = ["SSH"]
volume_size = "30"                                      # Larger volume to fit DOCA install
image_disk_format = "raw"
ssh_keypair_name = "dl-ansible-01"                      # Temporary, for access to the build VM
ssh_private_key_file = "/home/ubuntu/.ssh/id_rsa"       # Temporary, for access to the build VM
