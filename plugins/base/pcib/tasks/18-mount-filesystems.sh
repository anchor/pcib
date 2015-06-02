# The list of mount points, in shortest-to-longest order, so we mount them
# correctly inside one another
mount_list=($(for k in "${!PARTITIONS[@]}"; do echo "$k"; done | awk '{ print length(), $1 }' | sort -n | cut -d ' ' -f 2))

debug "Mount list is ${mount_list[@]}"

cleanup_mount_filesystem() {
	[ "$unmount_safely" = safe ] || warning "Performing unsafe unmounts"
	while [ "${#mount_list[@]}" -gt "0" ]; do
		p="${mount_list[-1]}"
		unset mount_list[${#mount_list[@]}-1]
		debug "Unmounting '$TARGET$p'"
		unmount_filesystem "$TARGET$p" "$unmount_safely"
	done
}

unmount_safely=
register_cleanup cleanup_mount_filesystem

for part in "${mount_list[@]}"; do
	if ! [[ "$part" =~ ^/ ]]; then
		# Not a mountable filesystem
		continue
	fi

	mkdir -p "${TARGET}${part}"
	debug "Mounting '${PARTITIONS[$part]}' on '${TARGET}${part}'"

	mount_filesystem "${PARTITIONS[$part]}" "${TARGET}${part}"
done
