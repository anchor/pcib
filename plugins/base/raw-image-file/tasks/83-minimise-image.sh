case "$FILESYSTEM" in
	ext*)
		for part in "${!PARTITIONS[@]}"; do
			zerofree "${PARTITIONS[$part]}" -v 2>&1 | spin "Compacting raw image file for partition $part"
		done
		;;
	*)
		# Do nothing.
		;;
esac
