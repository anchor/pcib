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

user_admin_usage() {
	usage_section "Create an admin user"

	usage_description \
		"Set up an admin user with full passwordless sudo."

	usage_option "admin-username" \
		"Specify the username for the admin user. May be specified as a" \
		"comma-separated list of usernames, in which case all listed"    \
		"users will be created. (default: admin)"

	usage_option "admin-authorized-keys" \
		"Specify a filename to copy into the image as the admin user's"
		"authorized_keys file. May be specified as a comma-separated"    \
		"list of colon-separated key-value pairs, with keys"             \
		"corresponding to usernames and values corresponding to"         \
		"filenames. If multiple usernames are specified, but only one"   \
		"key file is provided, then that authorized_keys file is"        \
		"installed for all admin users."

	usage_option "admin-shells" \
		"Specify a shell to use for the admin user. If a full path is"   \
		"given, all but the last component is ignored, and the basename" \
		"looked up in /etc/shells on the target system. May be"          \
		"specified as a comma-separated list of colon-separated"         \
		"key-value pairs, interpreted as with admin-authorized-keys."    \
		"(default: sh)"
}

parseopt admin-username true admin
admin_users="$(optval admin-username || :)"
admin_users=(${admin_users//,/ })

parseopt admin-authorized-keys true
admin_authorized_keys="$(optval admin-authorized-keys || :)"
admin_authorized_keys=(${admin_authorized_keys//,/ })

parseopt admin-shells true
