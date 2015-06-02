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

# Define this as a function, because we'll need to do it again after
# completing the yum bootstrap.
install_yum_repos() {
	rm -f "$TARGET"/etc/yum.repos.d/*.repo

	cat >"$TARGET"/etc/yum.repos.d/centos-base.repo <<-EOF
	[centos-base]
	name=CentOS-\$releasever - Base
	baseurl=$(optval mirror)/\$releasever/os/\$basearch/
	enabled=1
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$release_version

	[centos-base-debuginfo]
	name=CentOS-\$releasever - Base - Debug
	baseurl=$(optval mirror)/\$releasever/os/\$basearch/debug/
	enabled=0
	gpgcheck=1

	[centos-base-source]
	name=CentOS-\$releasever - Base - Source
	baseurl=$(optval mirror)/\$releasever/os/SRPMS/
	enabled=0
	gpgcheck=1
	EOF

	cat >"$TARGET"/etc/yum.repos.d/centos-updates.repo <<-EOF
	[centos-updates]
	name=CentOS-\$releasever - Updates
	baseurl=$(optval mirror)/\$releasever/updates/\$basearch/
	enabled=1
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$release_version

	[centos-updates-source]
	name=CentOS-\$releasever - Updates - Source
	baseurl=$(optval mirror)/\$releasever/updates/SRPMS/
	enabled=0
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-$release_version
	EOF
}

install_yum_repos
