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

cleanup_locks() {
	for pid in "${locks[@]}"; do
		[ -z "$pid" ] || kill "$pid"
	done
}
declare -A locks

lock() {
	local lock="$1"
	mkdir -p "$BASEDIR"/lock

	locks[$lock]="$( (
		if ! flock 9; then
			error "Unable to acquire lock for '$lock'"
			exit 1
		fi
		(
			# Hold the lock forever, or until we get killed.
			exec >/dev/null
			while :; do
				sleep 1
			done
		) &
		echo $!
	) 9>"$BASEDIR"/lock/"$lock" )"
}

unlock() {
	local lock="$1"

	[ -n "${locks[$lock]}" ] ||
		fatal "Attempt to release non-existent lock '$lock'"

	kill "${locks[$lock]}"
	locks[$lock]=
}
