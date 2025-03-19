#!/usr/bin/env bash
# Share images from one project to another
#
# usage:
#   share-images SOURCE_PROJECT DEST_PROJECT IMAGE_NAME
#
# NB: This requires a clouds.yaml file which uses project names as cloud keys

set -euo pipefail

SOURCE=$1
DEST=$2
IMAGE_NAME=$3

export OS_CLOUD=$SOURCE
SOURCE_PROJECT=$(openstack project show -c id -f value $SOURCE)
export OS_CLOUD=$DEST
DEST_PROJECT=$(openstack project show -c id -f value $DEST)
export OS_CLOUD=$SOURCE
IMAGE=$(openstack image show -c id -f value $IMAGE_NAME)

echo "Sharing $IMAGE_NAME ($IMAGE) from $SOURCE ($SOURCE_PROJECT) ..."
openstack image set --shared $IMAGE
echo "Adding destination project $DEST ($DEST_PROJECT) ..."
openstack image add project $IMAGE $DEST_PROJECT

export OS_CLOUD=$DEST
echo "Accepting share ..."
openstack image set --accept $IMAGE
echo "Done"
