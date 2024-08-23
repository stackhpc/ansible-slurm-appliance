#!/bin/bash

#####
# This script looks for an image in OpenStack and if not found, downloads from
# S3 bucket, and then uploads to OpenStack
#####

set -ex

image_name=$1
bucket_name=$2
echo "Checking if image $image_name exists in OpenStack"
image_exists=$(openstack image list --name "$image_name" -f value -c Name)

if [ -n "$image_exists" ]; then
    echo "Image $image_name already exists in OpenStack."
else
    echo "Image $image_name not found in OpenStack. Getting it from S3."

    wget https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_3a06571936a0424bb40bc5c672c4ccb1/$bucket_name/$image_name --progress=dot:giga

    echo "Uploading image $image_name to OpenStack..."
    openstack image create --file $image_name --disk-format qcow2 $image_name --progress

    echo "Image $image_name has been uploaded to OpenStack."
fi