#!/bin/sh
set -xe

for i in aria2c xz qemu-img tar sed cp mv; do
    if ! command -v $i &> /dev/null
    then
        echo "$i could not be found, please install it first."
        exit
    fi
done

ARCH="arm64"
TALOS_VERSION="v1.9.2"
OCI_VM_SIZE="VM.Standard.A1.Flex"

[ ! -f "oracle-$ARCH.tar.xz" ] && aria2c "https://factory.talos.dev/image/7d4c31cbd96db9f90c874990697c523482b2bae27fb4631d5583dcd9c281b1ff/$TALOS_VERSION/oracle-$ARCH.raw.xz"

xz -d "oracle-$ARCH.raw.xz"

cp image_metadata.json image_metadata.json.bak
sed "s/SHAPENAMEREPLACEME/$OCI_VM_SIZE/g" image_metadata.json > image_metadata.json.tmp
mv image_metadata.json.tmp image_metadata.json

sed "s/OSVERSIONREPLACEME/$TALOS_VERSION/g" image_metadata.json > image_metadata.json.tmp
mv image_metadata.json.tmp image_metadata.json

qemu-img convert -f raw -O qcow2 oracle-arm64.raw oracle-arm64.qcow2
tar zcf oracle-arm64.oci oracle-arm64.qcow2 image_metadata.json

mv image_metadata.json.bak image_metadata.json

echo "Talos $TALOS_VERSION image for Oracle Cloud Infrastructure is ready."
echo "You can now upload the image to a storage bucket."

