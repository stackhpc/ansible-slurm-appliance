resource "openstack_blockstorage_volume_v3" "state" {
    name = "${var.cluster_name}-state" # last word used to label filesystem
    description = "State for control node"
    size = var.state_volume_size
    volume_type = var.state_volume_type
}

resource "openstack_blockstorage_volume_v3" "home" {

    # NB: Changes CANNOT be made to this resource's "address"
    # i.e. (label or for_each key)
    # else existing clusters may get home volumes deleted and recreated!

    count = var.home_volume_size > 0 ? 1 : 0

    name = "${var.cluster_name}-home"  # last word used to label filesystem
    description = "Home for control node"
    size = var.home_volume_size
    volume_type = var.home_volume_type
}

data "openstack_blockstorage_volume_v3" "home" {

/*  May or may not have a volume, depending on home_volume_enabled, so this
    has to use for_each.

    For the case where we use the above provisioned volume resource, we need
    to create a depenency on it to avoid a race.

    The logic is:
    - If not home_volume_enabled, there is no volume
    - Else if home_volume_size > 0 - use the provisioned volume resource
    - Else find an existing volume with the specified name
*/
    
    for_each =  toset(
                    (var.home_volume_enabled) ? (
                        (var.home_volume_size > 0) ? 
                            [for v in openstack_blockstorage_volume_v3.home: v.name] :
                                ["${var.cluster_name}-home"]
                    ) : []
                )

    name = each.key
}
