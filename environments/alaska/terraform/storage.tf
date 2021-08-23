data "openstack_blockstorage_volume_v3" "home" {
  name = "alaska-home"
}

data "openstack_blockstorage_volume_v3" "slurmcltd" {
  name = "alaska-slurmctld-state"
}
