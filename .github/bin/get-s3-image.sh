#!/bin/bash

set -x

# Variables (adjust these paths as necessary)
S3_BUCKET="s3://openhpc-images"
APPLIANCES_ENVIRONMENT_ROOT="$APPLIANCES_ENVIRONMENT_ROOT"
MAIN_TF="$APPLIANCES_ENVIRONMENT_ROOT/terraform/main.tf"

for IMAGE_OS in $IMAGE_LIST; do
    echo "Extracting CI image name from $MAIN_TF"
    ci_image=$(grep -oP 'openhpc-[0-9a-zA-Z-]+' "$MAIN_TF" | grep $IMAGE_OS)

    echo "Checking if image $ci_image exists in OpenStack"
    image_exists=$(openstack image list --name "$ci_image" -f value -c Name)

    if [ "$image_exists" == "$ci_image" ]; then
        echo "Image $ci_image already exists in OpenStack."
    else
        echo "Image $ci_image not found in OpenStack. Getting it from S3."

        wget https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_3a06571936a0424bb40bc5c672c4ccb1/openhpc-images/$ci_image

        echo "Uploading image $ci_image to OpenStack..."
        openstack image create --file "$ci_image.qcow2" --disk-format qcow2 "$ci_image"

        echo "Image $ci_image has been uploaded to OpenStack."
    fi
done