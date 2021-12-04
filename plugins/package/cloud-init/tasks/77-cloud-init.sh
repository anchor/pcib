OS_VERSION=$(sysctl -n kern.osrelease)

git clone -b main http://github.com/goneri/cloud-init $TARGET/tmp/cloud-init

echo 'nameserver 8.8.8.8' > $TARGET/etc/resolv.conf

pkgs="
   bash
   dmidecode
   py3-configobj
   py3-jinja2
   py3-jsonschema
   py3-oauthlib
   py3-requests
   py3-setuptools
   py3-six
   py3-yaml
   sudo--
"
for pkg in ${pkgs}; do
    PKG_PATH="https://mirror.csclub.uwaterloo.ca/pub/OpenBSD/${OS_VERSION}/packages/amd64/" chroot $TARGET pkg_add ${pkg}
done
chroot $TARGET ldconfig /usr/local/lib
PKG_PATH="https://mirror.csclub.uwaterloo.ca/pub/OpenBSD/${OS_VERSION}/packages/amd64/" chroot $TARGET sh -c 'cd /tmp/cloud-init; ./tools/build-on-openbsd'

echo "#!/bin/sh" > $TARGET/etc/rc.local
echo "/usr/local/bin/cloud-init init -l" >> $TARGET/etc/rc.local
echo "/usr/local/bin/cloud-init init" >> $TARGET/etc/rc.local
echo "/usr/local/bin/cloud-init modules --mode config" >> $TARGET/etc/rc.local
echo "/usr/local/bin/cloud-init modules --mode final" >> $TARGET/etc/rc.local
cat /var/log/cloud-init.log > /dev/tty00
echo "exit 0" >> $TARGET/etc/rc.local

rm -r $TARGET/tmp/cloud-init
