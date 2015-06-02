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

install_ssh_key() {
	local user="$1"
	local key="$2"

	mkdir -p "$TARGET"/home/"$user"/.ssh
	cat "$key" >>"$TARGET"/home/"$user"/.ssh/authorized_keys
	run_in_target chown -R "$user": /home/"$user"
}

for user in "${admin_users[@]}"; do
	debug "Creating admin user $user with shell ${admin_shells["$user"]}"
	create_user "$user" "$user" "" "${admin_shells["$user"]}"
	grant_full_sudo "$user"
done

for key in "${admin_authorized_keys[@]}"; do
	IFS=':' read user key <<<"$key"
	if [ -n "$key" ]; then
		install_ssh_key "$user" "$key"
	else
		key="$user"
		for user in "${admin_users[@]}"; do
			install_ssh_key "$user" "$key"
		done
	fi
done
