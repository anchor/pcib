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

status() {
	colour="$1"; shift
	printf '\033[%sm%s\033[0m\n' "$colour" "$*" >&2
}

debug() {
	[ "$DEBUG" = y ] || return 0
	# Magenta.
	status '0;35' DEBUG: "$@"
}

info() {
	# Cyan.
	status '0;36' INFO: "$@"
}

warning() {
	# Yellow.
	status '0;33' WARNING: "$@"
}

error() {
	# Red.
	status '0;31' ERROR: "$@"
}

fatal() {
	# If we're failing from an init.sh, and the user has requested help,
	# let things fall through to the usage message.
	if optval help &>/dev/null; then
		return
	fi

	error "$@"
	exit 1
}

spin() {
	local msg="$*"
	local char='|'

	while read line; do
		[ -z "$WORKSPACE" ] || echo "$line" >>"$WORKSPACE"/build.log
		printf '\r%s: %s' "$msg" "$char" >&2
		case "$char" in
			\|) char=/  ;;
			/)  char=-  ;;
			-)  char=\\ ;;
			\\) char=\| ;;
		esac
	done

	printf '\r%s: \033[0;32mDone!\033[0m\n' "$msg" >&2
}

logpipe() {
	[ -n "$WORKSPACE" ] || fatal "Unable to log prior to setting up workspace."
	cat >>"$WORKSPACE"/build.log
}
