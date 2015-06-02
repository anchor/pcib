# Copyright (c) 2015 Anchor Systems Pty Ltd <support@anchor.com.au>
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

for part in "${!PARTITIONS[@]}"; do
	case "$part" in
		/*)
			;;
		*)
			# Not a regular filesystem partition; leave it alone.
			continue
			;;
	esac

	# We need to format the raw (character) device, not the block
	# device.
	to_format="$(sed 's,dev/,dev/r,' <<<"${PARTITIONS[$part]}")"

	if ! newfs "$to_format" |& spin "Formatting '$part' filesystem"; then
		fatal "Failed to format ${PARTITIONS[$part]} for $part"
	fi
done
