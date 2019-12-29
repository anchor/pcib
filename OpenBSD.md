Build OpenBSD 6.6 image
=======================

```shell
sudo pkg_add coreutils bash gsed flock bash
git clone https://github.com/goneri/pcib
cd pcib
sudo mkdir /var/cache/pcib
sudo ./bin/pcib --config examples/openstack-openbsd66
```
