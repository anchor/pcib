#!/bin/bash
# entry-point for the Cloud-Init BSD CI
version=$1
repo=$2
ref=$3
debug=$4
if [ -z "$version" ]; then
    version="12.1"
fi
if [ -z "${repo}" ]; then
    repo="canonical/cloud-init"
fi
if [ -z "${ref}" ]; then
    ref="master"
fi
if [ -z "${debug}" ]; then
    debug=""
fi
set -eux


echo "os=openbsd
mirror=http://mirror.csclub.uwaterloo.ca/pub/OpenBSD
arch=amd64
release=${version}

plugin=base/bootable
dhcp-interface=vio0

plugin=base/raw-image-file
image-basename=openstack-openbsd${version}
image-size=2

plugin=partitioner/disklabel
plugin=package/cloud-init
plugin=fs/ffs
plugin=package/sshd" > /tmp/openstack-openbsd


mkdir -p ~/builder
sudo mkdir -p /var/cache/pcib
sudo ./bin/pcib --config /tmp/openstack-openbsd
mv /var/cache/pcib/images/openstack-openbsd*.img ~/builder/final.raw
