resource "openstack_blockstorage_volume_v3" "state" {

    # NB: Changes to this resource's "address" i.e. (label or for_each key)
    # may lose state data for existing clusters using this volume

    count = var.state_volume_provisioning == "manage" ? 1 : 0

    name = "${var.cluster_name}-state" # last word used to label filesystem
    description = "State for control node"
    size = var.state_volume_size
    volume_type = var.state_volume_type
}

data "openstack_blockstorage_volume_v3" "state" {

/*  We use a data resource whether or not TF is managing the volume, so the
    logic is all in one place. But that means this needs a dependency on the
    actual resource to avoid a race.

    Because there may be no volume, this has to use for_each.
*/

    for_each = toset(
        (var.state_volume_provisioning == "manage") ?
            [for v in openstack_blockstorage_volume_v3.state: v.name] :
                ["${var.cluster_name}-state"]
    )

    name = each.key

}

resource "openstack_blockstorage_volume_v3" "home" {

    # NB: Changes to this resource's "address" i.e. (label or for_each key)
    # may lose user data for existing clusters using this volume

    count = var.home_volume_provisioning == "manage" ? 1 : 0

    name = "${var.cluster_name}-home"  # last word used to label filesystem
    description = "Home for control node"
    size = var.home_volume_size
    volume_type = var.home_volume_type
}

data "openstack_blockstorage_volume_v3" "home" {

/*  Comments as for the state volume. */

    for_each = toset(
        (var.home_volume_provisioning == "manage") ?
            [for v in openstack_blockstorage_volume_v3.home: v.name] :
                (var.home_volume_provisioning == "attach") ?
                    ["${var.cluster_name}-home"] :
                        []
    )

    name = each.key
}
