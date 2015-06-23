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

cleanups=()

register_cleanup() {
	debug "Registering cleanup: $1"
	cleanups=("${cleanups[@]}" "$1")
}

run_cleanups() {
	local target="$1"
	debug "Running cleanups up to $target"

	while [ -n "$cleanups" ]; do
		# "cleanups[-1]" is a bash-4ism, and doesn't even work correctly
		# on all bash 4 versions. Calculating a positive index enables us
		# to run on older systems.
		local i=$((${#cleanups[@]}-1))
		local cleanup="${cleanups[$i]}"
		unset cleanups[$i]

		debug "Running cleanup: $cleanup"
		"$cleanup"

		[ "$cleanup" != "$target" ] || break
	done
}
