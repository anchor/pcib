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

usage=()

register_usage() {
	usage=("${usage[@]}" "$1")
}

usage() {
	local begun=
	for u in "${usage[@]}"; do
		[ -z "$begun" ] || printf '\n' >&2
		begun=1
		"$u"
	done
}

usage_section() {
	# Bold yellow.
	status '1;33' "$1"
}

usage_description() {
	for part in "$@"; do
		# Green.
		status '0;32' "$part"
	done
}

usage_option() {
	printf '\n'

	# Bold cyan.
	status '1;36' "$1"
	shift

	for part in "$@"; do
		# Cyan.
		status '0;36' "$part"
	done
}
