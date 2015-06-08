# Copyright (c) 2015 Steven McDonald <steven@steven-mcdonald.id.au>
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

base_bootable_usage() {
	usage_section "Bootable"
	usage_description "Makes an image bootable." \
		"Without this plugin, an image will only be useful in a container or"      \
		"chroot."

	usage_option "--dhcp-interface <interface>" \
		"A network interface to configure using DHCP. May be specified multiple"   \
		"times."
}

register_usage base_bootable_usage

dhcp_interfaces=()
parseopt dhcp-interface true
while optval dhcp-interface &>/dev/null; do
	dhcp_interfaces=("${dhcp_interfaces[@]}" "$(optval dhcp-interface)")
	parseopt dhcp-interface true
done
