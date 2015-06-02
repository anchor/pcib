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

repo_epel_plugin_usage() {
	usage_section "EPEL"

	usage_description \
		"This plugin enables Extra Packages for Enterprise Linux."

	usage_option "--epel-mirror <url>" \
		"The mirror from which to fetch packages. Defaults to --mirror," \
		"with any trailing 'centos' substituted with 'epel'."

	usage_option "--epel-gpgkey <url>" \
		"The URL from which to fetch the EPEL GPG key. May be specified" \
		"as either an absolute URL or a relative path; in the latter"    \
		"case, it is appended to --epel-mirror. Defaults to"             \
		"'RPM-GPG-KEY-EPEL-(--release)'."
}

register_usage repo_epel_plugin_usage

parseopt epel-mirror true
parseopt epel-gpgkey true
