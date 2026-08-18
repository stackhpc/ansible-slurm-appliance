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
  image_url="https://leafcloud.store/swift/v1/AUTH_f39848421b2747148400ad8eeae8d536/$bucket_name/$image_name"
  wget "$image_url" --progress=dot:giga

  image_id=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-image-id | sed 's/.*://')
  image_sha512=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-image-sha512 | sed 's/.*://')
  qcow2_sha512=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-qcow2-sha512 | sed 's/.*://')
  sbom_url=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-sbom-url | sed 's/.*://')

  sha512sum -c <<<"$qcow2_sha512 $image_name"

  echo "Uploading image $image_name to OpenStack..."
  openstack image create --file "$image_name" --disk-format qcow2 "$image_name" --progress
  echo "Image $image_name has been uploaded to OpenStack."
  openstack image set \
    --property "stackhpc_sbom=$sbom_url" \
    --property "stackhpc_original_image_id=$image_id" \
    --property "stackhpc_original_image_sha512=$image_sha512" \
    "$image_name" || true

  target_image_sha512="$(openstack image show -f json -c properties "${image_name}" | jq -r '.properties.os_hash_value')"
  if [ "$target_image_sha512" != "$qcow2_sha512" ]; then
    echo "Uploaded Image $image_name in QCOW2 format has unexpected $target_image_sha512 vs expected $qcow2_sha512"
    exit 1
  fi
fi
