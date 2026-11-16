#!/bin/bash

#####
# This script looks for an image in OpenStack and if not found, downloads from
# S3 bucket, and then uploads to OpenStack
#####

set -e

convert_raw=false
forced_image_id=""
help=false
keep=false

while getopts ":i:khr" Option
do
  case $Option in
    i ) forced_image_id="$OPTARG";;
    k ) keep=true ;;
    r ) convert_raw=true ;;
    h | * ) help=true ;;
  esac
done
shift $((OPTIND - 1))

if $help || [ -z "$2" ]; then
echo "Usage: $0 [-h] [-i FORCED_IMAGE_ID] [-k] [-r] IMAGE_NAME BUCKET_NAME [MORE_CREATE_OPTION...]

This script looks for an image in OpenStack and if not found, downloads from
S3 bucket, and then uploads to OpenStack.
It can convert the downloaded image to raw before uploading it.
It checks image integrity based on properties on the source S3 object.
It sets image properties for best performance.

Options:

  -h  show this help message
  -i  Force a specific image id, instead of reusing the one of the source image.
      You can use 'uuidgen --random' to pick a new image id.
  -k  keep downloaded and intermediate files
  -r  convert the image to raw before creating it

  MORE_CREATE_OPTIONS are options passed to openstack image create, eg. '--shared'
"
exit
fi

image_name="$1"
shift
bucket_name="$1"
shift

image_url="https://leafcloud.store/swift/v1/AUTH_f39848421b2747148400ad8eeae8d536/$bucket_name/$image_name"
raw_sha512=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-image-sha512 | sed 's/.*: //;s/\r//')
qcow2_sha512=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-qcow2-sha512 | sed 's/.*: //;s/\r//')
image_id=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-image-id | sed 's/.*: //;s/\r//')

if $convert_raw && ! which qemu-img &> /dev/null; then
  echo "E: needs qemu-img to convert qemu disk format to raw"
  exit 1
fi

if $convert_raw; then
  disk_format=raw
  expected_sha512="$raw_sha512"
  upload_file="$image_name.raw"
else
  disk_format=qcow2
  expected_sha512="$qcow2_sha512"
  upload_file="$image_name"
fi
if [ -n "$forced_image_id" ]; then
  expected_image_id="$forced_image_id"
else
  expected_image_id="$image_id"
fi

echo "Checking if image $image_name exists in OpenStack"
image_exists=$(openstack image list --name "$image_name" -f value -c Name)

if [ -n "$image_exists" ]; then
  target_image_format="$(openstack image show "${image_name}" -f value -c disk_format)"
  target_image_id="$(openstack image show "${image_name}" -f value -c id)"
  target_image_sha512="$(openstack image show -f json -c properties "${image_name}" | jq -r .properties.os_hash_value)"
  if [ "$target_image_format" != "$disk_format" ]; then
    echo "Image $image_name already exists in OpenStack but in unexpected disk format $target_image_format vs expected $disk_format"
    exit 1
  elif [ "$target_image_sha512" != "$expected_sha512" ]; then
    echo "Image $image_name already exists in OpenStack in $disk_format disk format with unexpected $target_image_sha512 vs expected $expected_sha512"
    exit 1
  elif [ "$target_image_id" != "$expected_image_id" ]; then
    echo "Image $image_name already exists in OpenStack in $disk_format disk format with id $target_image_id vs expected $expected_image_id"
    exit 1
  fi
  echo "Image $image_name already exists in OpenStack (disk format $disk_format, id $expected_image_id, checksum $target_image_sha512)."
else

  if $convert_raw && [ -f "$upload_file" ] && sha512sum -c <<<"$raw_sha512 $upload_file" &> /dev/null; then
      echo "Image $image_name not found in OpenStack but already downloaded and converted."
  elif [ -f "$image_name" ] && sha512sum -c <<<"$qcow2_sha512 $image_name" &> /dev/null; then
      [ -f "$upload_file" ] && rm "$upload_file"
      echo "Image $image_name not found in OpenStack but already downloaded."
  else
    echo "Image $image_name not found in OpenStack. Getting it from S3."
    [ -f "$image_name" ] && rm "$image_name"
      [ -f "$upload_file" ] && rm "$upload_file"
    wget "$image_url" --progress=dot:giga
    sha512sum -c <<<"$qcow2_sha512 $image_name"
  fi

  if $convert_raw && [ ! -f "$upload_file" ]; then
      echo "Converting image $image_name to raw disk format..."
      qemu-img convert -O raw "$image_name" "$upload_file"
      sha512sum -c <<<"$raw_sha512 $upload_file"
  fi

  echo "Uploading image $image_name to OpenStack..."
  set -x
  openstack image create --file "$upload_file" --disk-format "$disk_format" --id "$expected_image_id" "$image_name" --progress "$@"
  set +x
  echo "Image $image_name has been uploaded to OpenStack."

  target_image_sha512="$(openstack image show -f json -c properties "${image_name}" | jq -r '.properties.os_hash_value')"
  if [ "$target_image_sha512" != "$expected_sha512" ]; then
    echo "Uploaded Image $image_name in $disk_format format has unexpected $target_image_sha512 vs expected $expected_sha512"
    exit 1
  fi

  sbom_url=$(curl -sS -I "$image_url" | grep x-object-meta-stackhpc-sbom-url | sed 's/.*: //;s/\r//')
  openstack image set \
    --property "stackhpc_sbom=$sbom_url" \
    --property "stackhpc_original_image_id=$image_id" \
    --property "stackhpc_original_image_sha512=$raw_sha512" \
    "$image_name" || true

  mydir="$(realpath "$(dirname "$0")")"
  "$mydir/image-set-properties.sh" "$expected_image_id"

  if ! $keep; then
      echo "Cleaning files"
      rm "$image_name"
      $convert_raw && rm "$image_name.raw"
  fi
fi
