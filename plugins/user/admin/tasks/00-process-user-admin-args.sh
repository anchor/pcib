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

admin_shells_="$(optval admin-shells || :)"
admin_shells_=(sh ${admin_shells_//,/})
declare -A admin_shells
set_admin_shell() {
	local user="$1"
	local shell="${2/*\//}"
	debug "Setting shell for $user to $shell"
	admin_shells["$user"]="$shell"
}
parse_admin_shells() {
	local IFS=,
	for s in "${admin_shells_[@]}"; do
		IFS=: read user shell <<<"$s"
		if [ -n "$shell" ]; then
			set_admin_shell "$user" "$shell"
		else
			shell="$user"
			for user in "${admin_users[@]}"; do
				set_admin_shell "$user" "$shell"
			done
		fi
	done
}
parse_admin_shells
