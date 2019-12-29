#!/bin/bash
# entry-point for the Cloud-Init BSD CI

mkdir -p ~/builder
sudo mkdir -p /var/cache/pcib
sudo ./bin/pcib --config examples/openstack-openbsd66
mv /var/cache/pcib/images/openstack-openbsd66-*.img ~/builder/final.raw
