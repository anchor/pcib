# Copyright (c) 2015 Anchor Systems Pty Ltd <support@anchor.com.au>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Automatically resize the filesystem of an instance on first boot.
# Note that this script relies heavily on a partition layout containing
# one large 'a' partition and nothing else.

export PATH=/sbin:/bin:/usr/bin:/usr/sbin
umask 022

# Make sure we can write to /tmp by just mounting / read-write.
mount -u /dev/rd0a /

for disk in sd0 wd0; do
    fdisk -v ${disk} && break
done
fpart=3
dpart=a
echo "growing filesystem on disk ${disk}"
echo "(msdos partition $fpart, disklabel partition $dpart)"

set -- $(disklabel "$disk" | sed -n '/^total sectors: /h;${g;p;}')
sectors="$3"
echo "total number of sectors: ${sectors}"

set -- $(disklabel "$disk" | sed -n '/^  '"$dpart"':/h;${g;p;}')
offset="$3"
echo "partition start offset: ${offset}"

size="$(($sectors-$offset))"
echo "calculated new partition size: ${size}"

# Do this now, so that if something goes wrong we avoid an infinite
# loop.
echo -n "removing boot.conf: "
mount /dev/"$disk$dpart" /mnt
echo "set tty com0" > /mnt/etc/boot.conf
umount /mnt
echo "done."

echo -n "modifying fdisk partition: "
fdisk -e "$disk" >/dev/null <<EOF
edit $fpart
A6
n
$offset
$size
write
quit
EOF
echo "done."

echo -n "modifying disklabel partition: "
disklabel -E "$disk" >/dev/null <<EOF
b
$offset
$size
m $dpart
$offset
$size
4.2BSD
q
y
EOF
echo "done."

echo -n "growing filesystem: "
growfs -qys "$size" /dev/"$disk$dpart"
echo "done."

echo -n "checking filesystem: "
fsck_ffs -y /dev/"$disk$dpart" || sh
echo "done."

echo "rebooting system..."
exec reboot
