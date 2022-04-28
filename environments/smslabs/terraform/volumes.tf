resource "openstack_blockstorage_volume_v3" "control" {
    name = "${var.cluster_name}-control"
    description = "State for control node"
    size = 50 # GB
}
