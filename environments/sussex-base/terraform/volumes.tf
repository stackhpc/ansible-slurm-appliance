data "openstack_blockstorage_volume_v3" "state" {
    name = "${var.cluster_name}-state"
}
