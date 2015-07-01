os_debian_plugin_usage() {
	usage_section "Debian"

	usage_description \
		"This plugin installs a very minimal Debian."

	usage_option "--release <release>" \
		"(REQUIRED) The Debian release to install. May be specified"     \
		"either as a numeric version (e.g., 8) or as a release codename" \
		"(e.g., jessie)."

	usage_option "--arch <arch>" \
		"The architecture to build for. (Default: amd64)"                \
		"Valid values are i386 or amd64."                                \

	usage_option "--debootstrap-mirror <url>" \
		"The URL from which debootstrap will get packages. If not"       \
		"specified, this will default to the value of the --apt-mirror"  \
		"option."

	usage_option "--apt-mirror <url>" \
		"A mirror to use post-debootstrap."                              \
		"(Default: http://http.debian.net/debian)"                       \
		"This option instructs the installer to configure apt to"        \
		"download packages from the given package mirror."

	usage_option "--proxy <url>" \
		"Use the given URL as an HTTP proxy."
}

register_usage os_debian_plugin_usage

load_plugin_or_die os/linux-common

parseopt release true
case "$(optval release)" in
	"")
		fatal "Required option 'release' not provided. Try $0 --help."
		;;
	7|7.*|wheezy)
		release_version=7
		release_name=wheezy
		;;
	8|8.*|jessie)
		release_version=8
		release_name=jessie
		;;
	*)
		fatal "Unsupported Debian release: $(optval release)"
		;;
esac

parseopt arch true amd64
parseopt apt-mirror true http://http.debian.net/debian
parseopt debootstrap-mirror true "${OPTS[apt-mirror]}"
parseopt proxy true

if optval proxy >/dev/null; then
	export http_proxy="$(optval proxy)"
fi

if [ "$release_version" -ge 8 ]; then
	INIT_SYSTEM=systemd
else
	INIT_SYSTEM=sysvinit
fi

install_packages_in_target() {
	local orig_debian_frontend="$DEBIAN_FRONTEND"
	export DEBIAN_FRONTEND=noninteractive
	run_in_target apt-get -y install "$@" 2>&1 | spin "Installing $*"
	export DEBIAN_FRONTEND="$orig_debian_frontend"
}

uninstall_packages_from_target() {
	local orig_debian_frontend="$DEBIAN_FRONTEND"
	export DEBIAN_FRONTEND=noninteractive
	run_in_target apt-get -y remove --purge "$@" 2>&1 | spin "Uninstalling $*"
	export DEBIAN_FRONTEND="$orig_debian_frontend"
}

create_user() {
	local user="$1"
	local gecos="${2:-$user}"
	local pw="$3"
	local shell="$4"

	local shell_args
	if [ -n "$shell" ]; then
		local shell_="$(perl -ne 'print if m,/\Q'"$shell"'\E$,' </etc/shells)"
		if [ -z "$shell_" ]; then
			fatal "No such shell: $shell"
		fi
		shell_args=(--shell "$shell_")
	else
		shell_args=()
	fi

	run_in_target adduser --gecos "$gecos" \
	        --disabled-password "${shell_args[@]}" "$user" &>/dev/null

	if [ -n "$pw" ]; then
		echo "$user:$pw" | run_in_target chpasswd
	fi
}

dhcp_interface() {
	local if="$1"
	local filename=/etc/network/interfaces

	install_package_providing dhclient

	# Older Debians don't have /etc/network/interfaces.d.
	if [ "$release_version" -ge 8 ]; then
		filename=/etc/network/interfaces.d/"$(echo -n "$if" | perl -pe 's/[^\w\-]/_/g')"
		mkdir -p "$TARGET"/etc/network/interfaces.d
		>"$TARGET""$filename"
	fi

	cat >>"$TARGET""$filename" <<EOF
auto $if
iface $if inet dhcp
EOF
}

install_init_script() {
	[ "$INIT_SYSTEM" = sysvinit ] || fatal "install_init_script: This operating system does not support sysvinit"

	local file="$1"

	debug "Installing '$file' as an init script"
	cp "$file" "$TARGET"/etc/init.d/
	chmod 0755 "$TARGET"/etc/init.d/"$(basename "$file")"
	run_in_target update-rc.d "$(basename "$file")" defaults >/dev/null
}

find_package_containing() {
	local pkg_list
	local file="$1"

	# wheezy's apt-file has a bug that causes it to spam uninitialised
	# value warnings. These are *extremely* annoying when trying to
	# follow pcib's output, so discard stderr on older systems. We don't
	# do this on later systems because stderr is useful, when it's --
	# err, useful.
	if [ "$release_version" -lt 8 ]; then
		pkg_list=($(run_in_target apt-file -Fl search "$file" 2>/dev/null))
	else
		pkg_list=($(run_in_target apt-file -Fl search "$file"))
	fi

	# If there is only one package to install, return that.
	[ "${#pkg_list[@]}" -gt 1 ] || {
		echo "${pkg_list[0]}"
		return
	}

	# Now comes the fun bit. APT doesn't make it easy to determine what
	# the "best" package is, if multiple packages provide the same file,
	# and sometimes (e.g., sudo and sudo-ldap) installing the latter
	# package will cause the former to be removed.
	#
	# Our process for deciding which package to prefer is:
	#
	#   1. Select all packages with the highest Priority.
	#   2. If we still have multiple packages and one is Provided by all
	#      others, return that.
	#   3. If we still have multiple packages, complain. The caller must
	#      be modified to provide a more specific requirement.

	# "Find the package with the highest Priority" ain't easy in bash.
	local best_pkg_list=()
	local best_priority=extra
	local priorities
	declare -A priorities
	priorities[required]=0
	priorities[important]=1
	priorities[standard]=2
	priorities[optional]=3
	priorities[extra]=4

	for pkg in "${pkg_list[@]}"; do
		local pkg_priority=($(run_in_target apt-cache show "$pkg" | perl -nle 'print $1 if /^Priority: (.*)$/' | sort -u))
		if [ "${#pkg_priority[@]}" -gt 1 ]; then
			error "Multiple package priorities detected for '$pkg'."
			error "If you *really* want to implement the craziness required to support this, feel free."
			fatal "Otherwise, have your plugin provide more specific package requirements."
		fi

		pkg_priority="${pkg_priority[0]}"
		if [ "${priorities["$pkg_priority"]}" -le "${priorities["$best_priority"]}" ]; then
			if [ "${priorities["$pkg_priority"]}" -lt "${priorities["$best_priority"]}" ]; then
				best_pkg_list=()
			fi
			best_pkg_list=("${best_pkg_list[@]}" "$pkg")
			best_priority="$pkg_priority"
		fi
	done

	# Has that narrowed things down?
	[ "${#best_pkg_list[@]}" -gt 1 ] || {
		echo "${best_pkg_list[0]}"
		return
	}

	# Nope? Time for step 2.
	local bester_pkg_list=()
	local provided
	declare -A provided
	for pkg in "${best_pkg_list[@]}"; do
		local pkg_provides=($(run_in_target apt-cache show "$pkg" | perl -nle 'print join "\n", split /,\s*/, $1 if /^Provides: (.*)$/' | sort -u))
		for p in "${pkg_provides[@]}"; do
			# Exclude packages which Provide themselves (this makes
			# figuring out if a package has been provided by all others
			# below much more difficult if we allow it).
			[ "$p" != "$pkg" ] || continue
			provided["$p"]=$((${provided["$p"]}+1))
		done
	done
	for pkg in "${best_pkg_list[@]}"; do
		# Have we been provided by every other package in best_pkg_list
		# (i.e., 1 fewer times than the size of best_pkg_list)? We use &&
		# rather than -a here so that bash doesn't complain about using
		# -eq on an empty string.
		if [ -n "${provided["$pkg"]}" ] && [ "${provided["$pkg"]}" -eq $((${#best_pkg_list[@]}-1)) ]; then
			bester_pkg_list=("${bester_pkg_list[@]}" "$pkg")
		fi
	done

	# Are we there yet?
	[ "${#bester_pkg_list[@]}" -ne 1 ] || {
		echo "${bester_pkg_list[0]}"
		return
	}

	# If we *still* don't know what to install, give up.
	error "Unable to unambiguously install a package providing '${file}'."
	fatal "Please be more specific."
}

expand_command_path() {
	echo {/usr,}/{s,}bin/"$1"
}

install_kernel() {
	case "${OPTS[arch]}" in
		amd64) kernel=linux-image-amd64;;
		i386)  kernel=linux-image-686;;
		*)     fatal "Unknown architecture: ${OPTS[arch]}"
	esac

	install_packages_in_target "$kernel"
}

set_hostname() {
	echo "$1" >"$TARGET"/etc/hostname
}

selinux_relabel() {
	# Relabel selinux on first boot
	touch "$TARGET"/.autorelabel
}

selinux_disable() {
	if [ -e "$TARGET"/etc/selinux/config ]; then
		sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' "$TARGET"/etc/selinux/config
	fi
}
