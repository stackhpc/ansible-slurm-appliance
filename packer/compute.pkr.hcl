# "timestamp" template function replacement:s
locals { timestamp = formatdate("YYYYMMDD-hhmm", timestamp())}

source "openstack" "compute" {
    source_image_name = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64.qcow2"
    flavor = "vm.alaska.cpu.general.small"
    networks = ["a262aabd-e6bf-4440-a155-13dbc1b5db0e"]
    ssh_keypair_name = "slurm-app-ci"
    ssh_private_key_file = "~/.ssh/id_rsa"
    security_groups = ["default", "SSH"]
    ssh_bastion_host = "128.232.222.183"
    ssh_bastion_username = "slurm-app-ci"
    ssh_username = "rocky"
    ssh_timeout = "20m"
    ssh_bastion_private_key_file = "~/.ssh/id_rsa"
    image_visibility = "private"
    image_name = "slurm-compute-${local.timestamp}"
}

build {

    name = "compute"
  
    sources = [
        "openstack.compute",
    ]

    provisioner "ansible" {
        playbook_file = "/home/rocky/slurm-app-genericimgs/ansible/site.yml"
        groups = ["builder", "compute", "builder_compute" ]
        keep_inventory_file = true # for debugging
        use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
        extra_arguments = ["--limit", "builder", "-i", "./ansible-inventory.sh", "-v"]
    }
    
    post-processor "manifest" {
        custom_data  = {
            source = "${source.name}"
        }
    }
}
