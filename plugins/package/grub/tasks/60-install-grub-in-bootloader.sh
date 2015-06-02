cleanup_grub1_install() {
	kpartx -d /dev/mapper/hda
	dmsetup remove hda
}

if run_in_target which grub2-install &>/dev/null; then
	# CentOS is a little special.
	grub_install=grub2-install
	grub_mkconfig=/usr/sbin/grub2-mkconfig
	_boot_grub=/boot/grub2
else
	grub_install=grub-install
	grub_mkconfig=/usr/sbin/grub-mkconfig
	_boot_grub=/boot/grub
fi

mkdir -p "$TARGET""$_boot_grub"

case "$(run_in_target "$grub_install" --version)" in
	*\ 0.*)
		# Oh *man*... I thought grub2 was weird

		# Temporary device.map for grub installation purposes
		echo "(hd0) $BLOCK_DEVICE" >"$TARGET""$_boot_grub"/device.map

		register_cleanup cleanup_grub1_install

		# http://ebroder.net/2009/08/04/installing-grub-onto-a-disk-image/
		# gave me the nasty details of this one

		blocks=$(($(optval image-size) * 2097152))
		maj_num=$((0x$(stat -c %t "$BLOCK_DEVICE")))
		min_num=$((0x$(stat -c %T "$BLOCK_DEVICE")))

		echo "0 $blocks linear $maj_num:$min_num 0" | dmsetup create hda
		kpartx -a /dev/mapper/hda

		# Setup some dummy files
		echo "(hd0) /dev/mapper/hda" >"$TARGET""$_boot_grub"/device.map

		if ! optval lvname >/dev/null; then
			 echo "/dev/mapper/hda1 / ext4 defaults 0 0" >"$TARGET"/etc/mtab
		else
			 echo "/dev/mapper/hda1 /boot ext3 defaults 0 0" >"$TARGET"/etc/mtab
			echo "/dev/mapper/hda2 / ext4 defaults 0 0" >>"$TARGET"/etc/mtab
		fi

		run_in_target "$grub_install" /dev/mapper/hda >/dev/null 2>&1

		# Replace with a real device.map
		echo "(hd0) /dev/vda" >"$TARGET""$_boot_grub"/device.map
		rm -f "$TARGET"/etc/mtab
		;;
	*\ 1.99*)
		cp "$TARGET"/usr/lib/grub/i386-pc/* "$TARGET""$_boot_grub"/

		if ! optval lvname >/dev/null; then
			grub_dir="$_boot_grub"
		else
			grub_dir=/grub
		fi
		run_in_target grub-mkimage -d /usr/lib/grub/i386-pc -O i386-pc \
			--output="$_boot_grub"/core.img --prefix="(,1)${grub_dir}" \
			biosdisk ext2 part_msdos

		# Final, real device.map for boot
		echo "(hd0) /dev/vda" >"$TARGET""$_boot_grub"/device.map

		run_in_target grub-setup -d "$_boot_grub" --root-device='(hd0)' "$BLOCK_DEVICE"
		;;
	*)
		echo "(hd0) /dev/vda" >"$TARGET""$_boot_grub"/device.map

		run_in_target "$grub_install" "$BLOCK_DEVICE" 2>&1 | spin "Installing GRUB to MBR"
		;;
esac
