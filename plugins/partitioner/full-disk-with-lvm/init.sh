misc_lvm_target_plugin_usage() {
	usage_section "LVM partitioner"

	usage_description \
		"Perform disk partitioning using Linux LVM."

	usage_option "--vgname <name>" \
		"Create the LV on the specified VG."

	usage_option "--lvname <name>" \
		"Create the root LV with the specified name."

	usage_option "--lvsize <size>" \
		"Create the LV with the specified size. The format is that"      \
		"accepted by lvcreate(8). (default: image size - 1G)"
}

register_usage misc_lvm_target_plugin_usage

parseopt vgname true
parseopt lvname true
parseopt lvsize true "$(( ${OPTS[image-size]} - 1 ))G"

# Convenience function.
# lvm_device_path <vgname> <lvname> -> <device node>
lvm_device_path() {
	local vgname="$1"
	local lvname="$2"

	echo /dev/mapper/"${vgname//-/--}"-"${lvname//-/--}"
}
