remunge_defaults=

# This is a workaround for the fact that partitioner/full-disk-with-lvm
# uses a temporary VG name for the build to enable parallelism, and we
# want the image to end up with the final VG name.
case "$(run_in_target "$grub_install" --version)" in
	*\ 1.99*|*\ 2.*)
		if optval lvname >/dev/null; then
			echo GRUB_DEVICE="$(lvm_device_path "$(optval vgname)" "$(optval lvname)")" >>"$TARGET"/etc/default/grub
			# If GRUB "detects" that the path we've given it isn't an LVM
			# path, it will use the UUID of the mounted root filesystem
			# instead.
			echo GRUB_DISABLE_LINUX_UUID=true >>"$TARGET"/etc/default/grub
			remunge_defaults=y
		fi
		;;
	*)
		;;
esac

# This is a workaround for some older versions of GRUB2 which don't
# correctly detect the root device's UUID in a chroot.
case "$(run_in_target "$grub_install" --version)" in
	*\ 1.99*)
		if ! optval lvname >/dev/null; then
			echo GRUB_DEVICE_UUID="$(blkid -s UUID -o value "${PARTITIONS[/]}")" >>"$TARGET"/etc/default/grub
			remunge_defaults=y
		fi
		;;
	*)
		;;
esac

if [ -x "$TARGET"/usr/sbin/update-grub ]; then
	run_in_target /usr/sbin/update-grub 2>&1 | spin "Configuring GRUB"
elif [ -x "$TARGET""$grub_mkconfig" ]; then
	run_in_target "$grub_mkconfig" 2>&1 >"$TARGET""$_boot_grub"/grub.cfg | spin "Configuring GRUB"
else
	if [ ! -e "$TARGET"/etc/grub.conf ]; then
		ln -s "$_boot_grub"/grub.conf "$TARGET"/etc/grub.conf
	fi

	if [ ! -e "$TARGET""$_boot_grub"/menu.lst ]; then
		ln -s "$_boot_grub"/grub.conf "$TARGET"/boot/grub/menu.lst
	fi

	if ! [ -e "$TARGET""$_boot_grub"/grub.conf ]; then
		kernel="$(basename "$(ls "$TARGET"/boot/vmlinuz*)")"
		if [ -z "$kernel" ]; then
			fatal "No kernel found"
		fi

		initrd="$(basename "$(ls "$TARGET"/boot/init*img*)")"
		if [ -z "$initrd" ]; then
			fatal "No initrd found"
		fi

		if ! optval lvname >/dev/null; then
			cat >"$TARGET""$_boot_grub"/grub.conf <<-EOF
			default=0
			timeout=5
			title Linux
				root (hd0,0)
				kernel /boot/$kernel ro root=/dev/vda1
				initrd /boot/$initrd
			EOF
		else
			cat >"$TARGET""$_boot_grub"/grub.conf <<-EOF
			default=0
			timeout=5
			title Linux
				root (hd0,0)
				kernel /$kernel ro root=$(lvm_device_path "$(optval vgname)" "$(optval lvname)")
				initrd /$initrd
			EOF
		fi
	fi
fi

if [ -n "$remunge_defaults" ]; then
	sed -i '/^GRUB_DEVICE=/d;/^GRUB_DEVICE_UUID=/d;/^GRUB_DISABLE_LINUX_UUID=/d' "$TARGET"/etc/default/grub
fi
