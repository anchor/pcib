[ -d "$(optval image-dir)" ] || mkdir -p "$(optval image-dir)"
output_file="$(optval image-dir)"/"$(optval image-basename)"-"$(date +%Y%m%d-%H%M%S)".img
mv "$IMAGEFILE" "$output_file"

case "$compress" in
	"")
		# Do nothing.
		;;
	bzip2)
		bzip2 "$output_file" | spin "Compressing image file with bzip2"
		output_file="$output_file".bz2
		;;
esac

info "Your box is now available in '${output_file}'"
