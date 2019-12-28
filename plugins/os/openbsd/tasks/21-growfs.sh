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

# Only one kernel build at a time, thanks.
lock growfs

#rm -rf /usr/src/distrib/amd64/ramdisk_growfs /usr/src/distrib/special/growfs
cp -r \
	"$(plugin_file os/openbsd usr/src/distrib/amd64/ramdisk_growfs)" \
	/usr/src/distrib/amd64/
cp -r \
	"$(plugin_file os/openbsd usr/src/distrib/special/growfs)" \
	/usr/src/distrib/special/
cp -r /usr/src/distrib/amd64/ramdiskA/list /usr/src/distrib/amd64/ramdisk_growfs

rm -rf /usr/obj/*
(cd /usr/src && make obj 2>&1) |
	spin "Populating /usr/obj"

(cd /usr/src/distrib/special && make 2>&1) |
	spin "Installing distribution tools"

(cd /usr/src/distrib/amd64/ramdisk_growfs && make bsd.rd 2>&1) |
	spin "Building growfs ramdisk kernel"

cp /usr/src/distrib/amd64/ramdisk_growfs/bsd.rd "$TARGET"/bsd.gf
unlock growfs

cat >"$TARGET"/etc/boot.conf <<EOF
boot hd0a:/bsd.gf
EOF
