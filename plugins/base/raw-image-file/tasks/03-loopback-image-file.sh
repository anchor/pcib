cleanup_loopback_image_file() {
	case "$(uname -s)" in
		Linux)
			losetup -d "$BLOCK_DEVICE" &>/dev/null
			;;
		OpenBSD)
			vnconfig -u "$DISK" &>/dev/null
			;;
		*)
			fatal "Unsupported operating system: $(uname -s)"
			;;
	esac
}

register_cleanup cleanup_loopback_image_file

case "$(uname -s)" in
	Linux)
		BLOCK_DEVICE="$(losetup --show -f "$IMAGEFILE")"
		CHARACTER_DEVICE="$BLOCK_DEVICE"
		DISK="${BLOCK_DEVICE/\/dev\//}"
		;;
	OpenBSD)
		# Avoid race conditions between finding an unused vnd and
		# configuring it.
		lock vnconfig
		DISK="$(vnconfig -l | perl -nle 'if (/^(vnd([1-9]|\d{2,})): not in use$/) {print $1; exit}')"
		[ -n "$DISK" ] || fatal "Unable to find a free vnode device"
		vnconfig "$DISK" "$IMAGEFILE"
		unlock vnconfig

		BLOCK_DEVICE=/dev/"$DISK"c
		CHARACTER_DEVICE=/dev/r"$DISK"c
		;;
	*)
		fatal "Unsupported operating system: $(uname -s)"
		;;
esac

if ! [ -b "$BLOCK_DEVICE" ]; then
	fatal "'$BLOCK_DEVICE' is not a block device"
fi

# Linux doesn't know how to distinguish block and character devices.
if ! [ -b "$CHARACTER_DEVICE" -o -c "$CHARACTER_DEVICE" ]; then
	fatal "'$CHARACTER_DEVICE' is not a character device"
fi
