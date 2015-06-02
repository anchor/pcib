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

cp "$(plugin_file repo/m-tier usr/local/sbin/openup)" "$TARGET"/usr/local/sbin/
chmod 0755 "$TARGET"/usr/local/sbin/openup

# openup doesn't use /etc/pkg.conf, so we need to configure this
# separately.
cat >"$TARGET"/etc/openup.conf <<-EOF
	PKG_PATH_MAIN=$(optval mirror)/$(optval release)/packages/$(optval arch)
	EOF
chmod 0600 "$TARGET"/etc/openup.conf

run_in_target openup | spin "Installing security updates from M:Tier"

# M:Tier's kernel binpatch will link the SMP kernel as /bsd iff the
# running system has multiple CPUs. But with an image build, the
# running system isn't relevant to the kernel being installed. In order
# to properly support an instance with any number of cores, make sure
# /bsd is always SMP-capable.
if [ -e "$TARGET"/bsd.mp ]; then
	mv -f "$TARGET"/bsd "$TARGET"/bsd.sp
	mv "$TARGET"/bsd.mp "$TARGET"/bsd
fi
