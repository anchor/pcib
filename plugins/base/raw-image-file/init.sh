# Copyright (c) 2015 Steven McDonald <steven@steven-mcdonald.id.au>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

raw_image_file_usage() {
	usage_section "Raw image file"
	usage_description "Provides a raw-format image file."

	usage_option "--compress <alg>" \
		"Compress the image using the specified algorithm."

	usage_option "--image-basename <name>" \
		"Required. The basename to use for the final image."

	usage_option "--image-size <size>" \
		"Required. The size of the image in GB."
}

parseopt compress true ""
case "$(optval compress)" in
	""|bzip2) ;;
	*) fatal "Unsupported compression algorithm: $(optval compress)" ;;
esac

parseopt image-basename true
if ! optval image-basename &>/dev/null; then
	fatal "No image-basename provided."
fi

parseopt image-size true
if ! optval image-size &>/dev/null; then
	fatal "No image-size provided."
fi
