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

declare -A OPTS

parseopt() {
	local opt="$1"
	local val="$2"
	local def="$3"

	# Reset any previously parsed option to default value (for
	# multivalue opts).
	if [ -n "$def" ]; then
		OPTS["$opt"]="$def"
	else
		unset OPTS["$opt"]
	fi

	for i in "${!ARGV[@]}"; do
		if [ "${ARGV[$i]}" = --"$opt" ]; then
			unset ARGV[$i]
			if [ "$val" = true ]; then
				OPTS["$opt"]="${ARGV[$(($i+1))]}"
				unset ARGV[$(($i+1))]
			else
				OPTS["$opt"]=y
			fi
			return
		fi
	done

	for i in "${!CONFIG_ARGV[@]}"; do
		if [ "${CONFIG_ARGV[$i]}" = --"$opt" ]; then
			unset CONFIG_ARGV[$i]
			if [ "$val" = true ]; then
				OPTS["$opt"]="${CONFIG_ARGV[$(($i+1))]}"
				unset CONFIG_ARGV[$(($i+1))]
			else
				OPTS["$opt"]=y
			fi
			return
		fi
	done
}

optval() {
	local opt="$1"

	# Do we actually have the requested option?
	if [ -z "${OPTS["$opt"]:+yes}" ]; then
		return 1
	fi

	echo "${OPTS["$opt"]}"
}
