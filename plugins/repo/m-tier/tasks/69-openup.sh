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

# This needs to come after all other rc.firsttime fragments, because
# the reboot will halt rc.firsttime processing (and it won't get
# sourced again on second boot).

# FIXME: We should be able to reboot conditionally. It's safe to do so
# unconditionally, since rc.firsttime is guaranteed not to be run
# multiple times, but may be wasteful if there are no updates.
# Unfortunately, openup provides no easy mechanism to determine if
# there were updates.
cat >>"$TARGET"/etc/rc.firsttime <<-'EOF'
	echo "installing updates from M:Tier"
	/usr/local/sbin/openup
	echo -n "rebooting... "
	reboot
	echo "failed!"
	exit 1
	EOF
