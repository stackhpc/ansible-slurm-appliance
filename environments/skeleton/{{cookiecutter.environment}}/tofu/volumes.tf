resource "openstack_blockstorage_volume_v3" "state" {
    name = "${var.cluster_name}-state" # last word used to label filesystem
    description = "State for control node"
    size = var.state_volume_size
    volume_type = var.state_volume_type
}

resource "openstack_blockstorage_volume_v3" "home" {

    count = var.home_volume_size > 0 ? 1 : 0

    name = "${var.cluster_name}-home"  # last word used to label filesystem
    description = "Home for control node"
    size = var.home_volume_size
    volume_type = var.home_volume_type
}
