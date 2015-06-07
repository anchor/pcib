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

SETDIR="$BASEDIR"/openbsd/"$(optval release)"/"$(optval arch)"
mkdir -p "$SETDIR"

for set in SHA256.sig $sets "$(optval kernel)" bsd.rd; do
	if [ ! -e "$SETDIR"/"$set" ] && ! ftp -MVo "$SETDIR"/"$set" "$download_base"/"$set"; then
		fatal "Error fetching '$set'."
	fi

	case "$set" in
		SHA256.sig)
			# First, we verify the signature once.
			if ! signify -qV -p /etc/signify/openbsd-"$release"-base.pub -x "$SETDIR"/SHA256.sig -m <(tail -n+3 "$SETDIR"/SHA256.sig); then
				fatal "Could not verify signature on '$set'."
			fi
			;;
		*)
			# Then, we verify each file's checksum.
			if ! (cd "$SETDIR" && sha256 -qC SHA256.sig "$set"); then
				fatal "Could not verify checksum for '$set'."
			fi
			;;
	esac
done

info "Successfully verified all signatures and checksums."
