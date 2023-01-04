flavor = "vm.alaska.cpu.general.small"
networks = ["a262aabd-e6bf-4440-a155-13dbc1b5db0e"] # WCDC-iLab-60
source_image_name = "openhpc-230104-1319.qcow2" # https://github.com/stackhpc/slurm_image_builder/pull/13
#source_image_name = "Rocky-8-GenericCloud-Base-8.7-20221130.0.x86_64.qcow2"
ssh_keypair_name = "slurm-app-ci"
security_groups = ["default", "SSH"]
ssh_bastion_host = "128.232.222.183"
ssh_bastion_username = "slurm-app-ci"
