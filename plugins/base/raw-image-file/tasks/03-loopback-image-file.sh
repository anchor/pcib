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

cleanup_loopback_image() {
	case "$(uname -s)" in
		Linux)
			losetup -d "$BLOCK_DEVICE" ||
				fatal "Unable to unconfigure loopback device."
			;;
		OpenBSD)
			vnconfig -u vnd"$vnd" ||
				fatal "Unable to unconfigure vnd(4) device."
			;;
	esac
}

register_cleanup cleanup_loopback_image

case "$(uname -s)" in
	Linux)
		BLOCK_DEVICE="$(losetup --show -f "$IMAGE")" ||
			fatal "Unable to configure loopback device."
		CHARACTER_DEVICE="$BLOCK_DEVICE"
		;;
	OpenBSD)
		lock vnd
		vnd="$(vnconfig -l | perl -ne 'if (/^vnd([1-9]|\d{2,}): not in use$/) { print $1; exit; }')"
		[ -n "$vnd" ] || fatal "No available vnd(4) found."

		vnconfig vnd"$vnd" "$IMAGE" ||
			fatal "Unable to configure vnd(4) device."
		unlock vnd

		DISK=vnd"$vnd"
		BLOCK_DEVICE=/dev/"$DISK"c
		CHARACTER_DEVICE=/dev/r"$DISK"c
		;;
	*)
		fatal "Unknown operating system: $(uname -s)"
		;;
esac
