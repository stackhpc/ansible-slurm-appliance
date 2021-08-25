data "openstack_blockstorage_volume_v3" "home" {
  name = var.home_volume
}

data "openstack_blockstorage_volume_v3" "slurmcltd" {
  name = var.slurmctld_volume
}
