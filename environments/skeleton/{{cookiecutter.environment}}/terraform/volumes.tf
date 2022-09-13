resource "openstack_blockstorage_volume_v3" "state" {
    name = "${var.cluster_name}-state"
    description = "State for control node"
    size = var.state_volume_size
}

resource "openstack_blockstorage_volume_v3" "home" {
    name = "${var.cluster_name}-home"
    description = "Home for control node"
    size = var.home_volume_size
}
