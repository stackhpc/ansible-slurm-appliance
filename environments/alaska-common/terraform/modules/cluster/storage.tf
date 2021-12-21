data "openstack_blockstorage_volume_v3" "home" {
  name = var.home_volume
}

data "openstack_blockstorage_volume_v3" "slurmctld" {
  name = var.slurmctld_volume
}
