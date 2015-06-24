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

install_systemd_unit() {
	[ "$INIT_SYSTEM" = systemd ] || fatal "install_systemd_unit: This operating system does not support systemd"

	local file="$1"
	local enable="$2"

	debug "Installing '$file' as a systemd unit"
	cp "$file" "$TARGET"/etc/systemd/system/

	if [ -n "$enable" ]; then
		run_in_target systemctl enable "$(basename "$file")" &>/dev/null
	fi
}

mount_filesystem() {
	local special="$1"
	local mountpoint="$2"

	mount -o noatime,barrier=0,data=writeback "$special" "$mountpoint"
}

unmount_filesystem() {
	local mountpoint="$1"
	local safe="$2"

	if [ "$safe" = safe ]; then
		umount "$mountpoint"
	else
		umount -lf "$mountpoint"
	fi
}

is_mountpoint() {
	mountpoint -q "$1"
}
