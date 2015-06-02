cleanup_create_image_file() {
	if [ "$BUILD_COMPLETE" = y -a -n "$IMAGEFILE" ]; then
		rm -f "$IMAGEFILE"
	fi
}

register_cleanup "cleanup_create_image_file"

IMAGEFILE="$WORKSPACE"/image.raw

dd if=/dev/zero of="$IMAGEFILE" bs=1M seek=$((1024*${OPTS[image-size]})) count=0 &>/dev/null
