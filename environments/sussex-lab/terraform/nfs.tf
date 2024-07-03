
data "openstack_blockstorage_volume_v3" "home" {
    name = "${var.cluster_name}-home"
}

resource "openstack_compute_instance_v2" "nfs_server" {

  name = "${var.cluster_name}-nfs"
  image_id = "1c86fcfd-fe5d-4225-952c-5b9f05632a57" # openhpc-ofed-RL9-240621-1308-96959324 # https://github.com/stackhpc/ansible-slurm-appliance/pull/401
  flavor_name = "en1.xsmall"
  key_pair = "slurm-app-ci"

  network {
    name = "sussex-storage"
    access_network = true
  }

  security_groups = ["${var.cluster_name}-cluster"]
  
  # root device:
  block_device {
      uuid = var.cluster_image_id
      source_type  = "image"
      destination_type = "local"
      boot_index = 0
  }

  # exported home volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = data.openstack_blockstorage_volume_v3.home.id
  }

  user_data = <<-EOF
    #cloud-config
    
    bootcmd:
      - BLKDEV=$(readlink -f $(ls /dev/disk/by-id/*${substr(data.openstack_blockstorage_volume_v3.home.id, 0, 20)}* | head -n1 )); blkid -o value -s TYPE $BLKDEV ||  mke2fs -t ext4 -L home $BLKDEV
      
    mounts:
      - [LABEL=home, /exports/home]
  EOF

  metadata = {
    environment_root = var.environment_root
  }
}

resource "local_file" "nfs" {
  content  = <<-EOT
  [nfs_server]
  ${openstack_compute_instance_v2.nfs_server.name} ansible_host=${[for n in openstack_compute_instance_v2.nfs_server.network: n.fixed_ip_v4 if n.access_network][0]} instance_id=${ openstack_compute_instance_v2.nfs_server.id }
  EOT
  filename = "../inventory/additional_hosts"
}
