#!/bin/bash

set -x

# Variables (adjust these paths as necessary)
S3_BUCKET="s3://openhpc-images"

for IMAGE_OS in $IMAGE_LIST; do
    
    image_name=$1
    echo "Checking if image $image_name exists in OpenStack"
    image_exists=$(openstack image list --name "$image_name" -f value -c Name)

    if [ "$image_exists" == "$image_name" ]; then
        echo "Image $image_name already exists in OpenStack."
    else
        echo "Image $image_name not found in OpenStack. Getting it from S3."

        wget https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_3a06571936a0424bb40bc5c672c4ccb1/openhpc-images/$image_name

        echo "Uploading image $image_name to OpenStack..."
        openstack image create --file "$image_name.qcow2" --disk-format qcow2 "$image_name"

        echo "Image $image_name has been uploaded to OpenStack."
    fi
done