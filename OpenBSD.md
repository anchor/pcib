Build OpenBSD 6.6 image
=======================

```shell
mkdir -p /usr/src /usr/obj
cd /usr/src
curl https://mirror.csclub.uwaterloo.ca/pub/OpenBSD/6.6/src.tar.gz|sudo tar xfz -
sudo pkg_add coreutils bash gsed flock bash
cd ~
git clone https://github.com/goneri/pcib
cd pcib
sudo mkdir /var/cache/pcib
sudo ./bin/pcib --config examples/openstack-openbsd66
```
