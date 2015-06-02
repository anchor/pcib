base_bootable_usage() {
	usage_section "bootable"

	usage_description \
		"This plugin makes an image bootable. Without this plugin,"      \
		"images will only be suitable for use in a container/chroot."

	usage_option "dhcp-interface" \
		"An interface to configure with DHCP. May be specified multiple" \
		"times."
}

register_usage base_bootable_usage

dhcp_interfaces=()
parseopt dhcp-interface true
while optval dhcp-interface &>/dev/null; do
	dhcp_interfaces=("${dhcp_interfaces[@]}" "$(optval dhcp-interface)")
	parseopt dhcp-interface true
done
