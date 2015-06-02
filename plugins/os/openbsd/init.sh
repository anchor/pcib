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

os_openbsd_plugin_usage() {
	usage_section "OpenBSD"

	usage_description \
		"This plugin installs OpenBSD."

	usage_option "--release <release>" \
		"(REQUIRED) The OpenBSD release to install."

	usage_option "--arch <arch>" \
		"The architecture to build for. (Default: amd64)"

	usage_option "--mirror <url>" \
		"The mirror from which to fetch the sets. Currently, only HTTP" \
		"mirrors are supported."

	usage_option "--sets <set,set,...>" \
		"Which sets to install. (Default: base,comp,man,xbase,xfont,"   \
		"xshare; i.e., everything but game and xserv)"

	usage_option "--kernel <bsd>" \
		"Which kernel to install. (Default: bsd.mp)"
}

register_usage os_openbsd_plugin_usage

parseopt release true
case "$(optval release)" in
	"")
		fatal "Required option 'release' not provided. Try $0 --help."
		;;
	*)
		if ! optval release | grep -Eq '^[0-9]+\.[0-9]$'; then
			fatal "Invalid OpenBSD release: $(optval release)"
		fi
		;;
esac

parseopt arch true amd64
parseopt mirror true http://ftp.openbsd.org/pub/OpenBSD
parseopt sets true
parseopt kernel true bsd.mp

download_base="$(optval mirror)"/"$(optval release)"/"$(optval arch)"
release="$(optval release | tr -d .)"

list_all_sets() {
	local sets
	if ! sets="$(optval sets)"; then
		if [ "$release" -ge 57 ]; then
			sets=base,comp,man,xbase,xfont,xshare
		else
			# Older versions of OpenBSD had separate base and etc sets.
			sets=base,comp,etc,man,xbase,xetc,xfont,xshare
		fi
	fi

	local IFS=,
	for set in $sets; do
		echo "$set""$release".tgz
	done
}
sets="$(list_all_sets)"

install_packages_in_target() {
	run_in_target pkg_add -I "$@" | spin "Installing $*"
}

uninstall_packages_from_target() {
	run_in_target pkg_delete -I "$@" | spin "Uninstalling $*"
}

create_user() {
	local user="$1"
	local gecos="${2:-$user}"
	local pw="$3"
	local shell="$4"

	local pw_args
	if [ -n "$pw" ]; then
		pw_args=(-p "$(encrypt <<<"$pw")")
	else
		pw_args=()
	fi

	local shell_args
	if [ -n "$shell" ]; then
		local shell_="$(perl -ne 'print if m,/\Q'"$shell"'\E$,' </etc/shells)"
		if [ -z "$shell_" ]; then
			fatal "No such shell: $shell"
		fi
		shell_args=(-s "$shell_")
	else
		shell_args=()
	fi

	run_in_target user add -m \
		-c "$gecos"        \
		"${pw_args[@]}"    \
		"${shell_args[@]}" \
		"$user"
}

dhcp_interface() {
	echo dhcp >"$TARGET"/etc/hostname."$1"
}

install_init_script() {
	fatal "install_init_script: OpenBSD does not support sysvinit."
}

install_pkglocatedb() {
	[ -e "$TARGET"/usr/local/bin/pkg_locate ] ||
		install_packages_in_target pkglocatedb
}

find_package_containing() {
	local to_find="$1"
	local best_pkg

	install_pkglocatedb

	while IFS=: read pkg port file; do
		# pkg_locate treats 'foo' as if it were '*foo*', so we need to
		# make sure we haven't matched only part of a path.
		[ "$file" = "$to_find" ] || continue

		# If we found multiple matches, and one of them *isn't* a
		# substring of the other (indicating a different flavour), then
		# bail.
		local best_pkg_suffix="$(perl -pe "s/\\Q$pkg\\E//" <<<"$best_pkg")"
		local pkg_suffix="$(perl -pe "s/\\Q$best_pkg\\E//" <<<"$pkg")"
		if [ -n "$best_pkg" -a "$best_pkg_suffix" = "$best_pkg" -a "$pkg_suffix" = "$pkg" ]; then
			fatal "Unable to unambiguously install a package containing '$to_find'."
		fi

		# This is our new best_pkg if we don't already have one, or if
		# best_pkg has a suffix.
		if [ -z "$best_pkg" -o "$best_pkg_suffix" != "$best_pkg" ]; then
			best_pkg="$pkg"
		fi
	done < <(run_in_target pkg_locate "$to_find")

	# We don't care about specific versions of packages; this can be
	# important when making use of the M:Tier package repo, which
	# includes updates not reflected by pkg_locate.
	sed -r 's/-[0-9A-Za-z.]+$//' <<<"$best_pkg"
}

expand_command_path() {
	echo {,/usr,/usr/local}/{s,}bin/"$1"
}

install_kernel() {
	# It's possible that a kernel has already been installed when
	# install_kernel is called; in particular, M:Tier's openup script
	# will install a kernel for us if it has already been invoked.
	[ -e "$TARGET"/bsd ] || cp "$SETDIR"/"$(optval kernel)" "$TARGET"/bsd
	[ -e "$TARGET"/bsd.rd ] || cp "$SETDIR"/bsd.rd "$TARGET"/bsd.rd
}

set_hostname() {
	echo "$1" >"$TARGET"/etc/myname
}

# SELinux isn't relevant to anything but Linux, funnily enough.
selinux_relabel() { :; }
selinux_disable() { :; }

mount_filesystem() {
	local special="$1"
	local mountpoint="$2"

	mount -o async,noatime "$special" "$mountpoint"
}

unmount_filesystem() {
	local mountpoint="$1"
	local safe="$2"

	if [ "$safe" = safe ]; then
		umount "$mountpoint"
	else
		umount -f "$mountpoint"
	fi
}
