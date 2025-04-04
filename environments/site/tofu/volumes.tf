data "openstack_blockstorage_volume_v3" "state" {
    name = "${var.cluster_name}-state" # last word used to label filesystem
}

data "openstack_blockstorage_volume_v3" "home" {
    name = "${var.cluster_name}-home"  # last word used to label filesystem
}
