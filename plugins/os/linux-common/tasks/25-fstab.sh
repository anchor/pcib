if ! optval lvname >/dev/null; then
	root_uuid="$(blkid -s UUID -o value "${PARTITIONS[/]}")"

	cat >"$TARGET"/etc/fstab <<-EOF
	UUID=$root_uuid / ext4 defaults 0 1
	EOF
else
	boot_uuid="$(blkid -s UUID -o value "${PARTITIONS[/boot]}")"

	cat >"$TARGET"/etc/fstab <<-EOF
	$(lvm_device_path "$(optval vgname)" "$(optval lvname)") / ext4 defaults 0 1
	UUID=$boot_uuid /boot ext4 defaults 0 2
	EOF
fi

if [ -n "$SWAP_DEVICE" ]; then
	cat >>"$TARGET"/etc/fstab <<-EOF
	$SWAP_DEVICE none swap sw 0 0
	EOF
fi
