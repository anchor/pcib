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

cat >"$TARGET"/etc/yum.repos.d/epel.repo <<-EOF
[epel]
name=Extra Packages for Enterprise Linux
baseurl=$epel_mirror/\$releasever/\$basearch/
enabled=1
gpgcheck=1
gpgkey=$epel_gpgkey

[epel-debuginfo]
name=Extra Packages for Enterprise Linux - Debug
baseurl=$epel_mirror/\$releasever/\$basearch/debug/
enabled=0
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux - Source
baseurl=$epel_mirror/\$releasever/SRPMS/
enabled=0
gpgcheck=1
EOF
