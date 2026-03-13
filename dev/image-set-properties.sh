#!/usr/bin/bash
# Set image properties correctly for Slurm Appliance images
#
# Usage:
#   dev/image-set-properties.sh $IMAGE_NAME_OR_ID

set -euo pipefail

image=${1?param missing - image name or ID}
echo getting image format ...
format=$(openstack image show -c disk_format -f value "${image}")

echo setting constant properties ...
set -x
openstack image set \
--property hw_machine_type=q35 \
--property hw_architecture=x86_64 \
--property hw_vif_multiqueue_enabled=true \
--property hw_firmware_type=uefi \
--property os_type=linux \
--property os_admin_user=rocky \
"$image"

set +x
if [[ "$format" = raw ]]; then
    echo setting raw properties...
    set -x
    openstack image set \
    --property hw_scsi_model=virtio-scsi \
    --property hw_disk_bus=scsi \
    "$image"
else
    echo setting qcow2 properties
    set -x
    openstack image set \
    --property hw_disk_bus=virtio \
    "$image"
fi
