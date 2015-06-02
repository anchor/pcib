debug "Formatting all filesystems for ext4..."

for part in "${!PARTITIONS[@]}"; do
	if ! [[ "$part" =~ ^/ ]]; then
		# Not a regular filesystem partition; leave it alone
		continue
	fi

	if ! mkfs.ext4 "${PARTITIONS[$part]}" |& spin "Formatting '$part' filesystem"; then
		fatal "Failed to format ${PARTITIONS[$part]} for $part"
	fi

	if ! tune2fs -c 0 -i 0 "${PARTITIONS[$part]}" |& spin "Tuning '$part' filesystem"; then
		fatal "Failed to tune ${PARTITIONS[$part]} for $part"
	fi
done
