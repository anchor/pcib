cleanup_mount_specials() {
	umount "$TARGET"/dev/pts
	umount "$TARGET"/sys
	umount "$TARGET"/proc
	umount "$TARGET"/dev
}

register_cleanup cleanup_mount_specials

mkdir -p "$TARGET"/dev
mount --bind /dev "$TARGET"/dev
mount -t proc none "$TARGET"/proc
mount -t sysfs none "$TARGET"/sys
mount -t devpts none "$TARGET"/dev/pts
