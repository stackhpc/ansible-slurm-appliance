resource "openstack_blockstorage_volume_v3" "state" {
    name = "${var.cluster_name}-state"
    description = "State for control node" # first word used to label filesystem
    size = var.state_volume_size
}

resource "openstack_blockstorage_volume_v3" "home" {

    count = var.home_volume_size > 0 ? 1 : 0

    name = "${var.cluster_name}-home"
    description = "Home for control node" # first word used to label filesystem
    size = var.home_volume_size
}
