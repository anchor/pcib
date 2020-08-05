OS_VERSION=$(sysctl -n kern.osrelease)

git clone -b master http://github.com/goneri/cloud-init $TARGET/tmp/cloud-init

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

gsed -i "/^echo 'starting network'/i \/usr\/local\/bin\/cloud-init --debug init -l" $TARGET/etc/rc
gsed -i "/^reorder_libs$/i \/usr\/local\/bin\/cloud-init --debug init" $TARGET/etc/rc
gsed -i "/.*rc.local.*/i \/usr\/local\/bin\/cloud-init --debug modules --mode config" $TARGET/etc/rc
gsed -i "/^date/i \/usr\/local\/bin\/cloud-init --debug modules --mode final" $TARGET/etc/rc

cat $TARGET/etc/rc

rm -r $TARGET/tmp/cloud-init
