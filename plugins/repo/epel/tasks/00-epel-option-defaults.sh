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

epel_mirror="$(optval epel-mirror)" || epel_mirror="$(optval mirror | sed -r 's,centos(/?)$,epel\1,i')"

if [[ "$(optval epel-gpgkey)" =~ ^[A-Za-z][A-Za-z+-.]*: ]]; then
	# We have a full URL.
	epel_gpgkey="$(optval epel-gpgkey)"
elif optval epel-gpgkey >/dev/null; then
	# We have a relative URL.
	epel_gpgkey="$epel_mirror"/"$(optval epel-gpgkey)"
else
	# Default.
	epel_gpgkey="$epel_mirror"/RPM-GPG-KEY-EPEL-"$release_version"
fi
