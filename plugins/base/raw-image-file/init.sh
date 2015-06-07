base_raw_image_file_usage() {
	usage_section "Raw image file"

	usage_description \
		"This plugin provides a raw image file for platform plugins to"  \
		"work their magic in."

	usage_option "image-size" \
		"Set the image size in GB."

	usage_option "image-dir" \
		"Specify the directory to place resultant images in. (default:"  \
		"\${basedir}/images)"

	usage_option "image-basename" \
		"Specify the basename to use for the image. This will have the"  \
		"current date and time, as well as a .img extension appended."   \
		"(default: avf)"

	usage_option "compress" \
		"The compression algorithm to use to compress the final image."  \
		"(default: no compression)"
}

register_usage base_raw_image_file_usage

parseopt image-size true 3
parseopt image-dir true "$BASEDIR"/images
parseopt image-basename true avf
parseopt compress true

compress="$(optval compress)" || :
case "$compress" in
	""|bzip2) ;;
	*) fatal "Unsupported compression algorithm: $compress" ;;
esac
