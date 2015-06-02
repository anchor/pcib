os_centos_plugin_usage() {
	usage_section "CentOS"

	usage_description \
		"This plugin installs a very minimal CentOS."

	usage_option "--release <release>" \
		"(REQUIRED) The CentOS release to install."

	usage_option "--arch <arch>" \
		"The architecture to build for. Currently, only x86_64 (the"     \
		"default) is supported."

	usage_option "--mirror <url>" \
		"(REQUIRED) The mirror from which to fetch packages."
}

register_usage os_centos_plugin_usage

load_plugin_or_die os/linux-common

parseopt release true
parseopt arch true x86_64
parseopt mirror true

release_version="$(optval release)" ||
	fatal "Must provide a CentOS release to build."
optval mirror >/dev/null ||
	fatal "Must provide a CentOS mirror."

if [ "$release_version" -ge 7 ]; then
	INIT_SYSTEM=systemd
else
	# CentOS 6 uses upstart, but in sysvinit-compatibility mode, so for
	# our purposes we can treat it as sysvinit.
	INIT_SYSTEM=sysvinit
fi

install_packages_in_target() {
	run_in_target yum -y install "$@" 2>&1 | spin "Installing $*"
}

uninstall_packages_from_target() {
	run_in_target yum -y erase "$@" 2>&1 | spin "Uninstalling $*"
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

	run_in_target useradd --comment "$gecos" \
		"${shell_args[@]}" "$user" &>/dev/null

	if [ -n "$pw" ]; then
		echo "$user:$pw" | run_in_target chpasswd
	fi
}

dhcp_interface() {
	local if="$1"

	# CentOS treats this as an "enable networking" flag.
	touch "$TARGET"/etc/sysconfig/network

	# Make sure we can actually *do* DHCP.
	install_package_providing dhclient

	cat >"$TARGET"/etc/sysconfig/network-scripts/ifcfg-"$if" <<-EOF
	DEVICE=$if
	ONBOOT=yes
	BOOTPROTO=dhcp
	EOF
}

install_init_script() {
	[ "$INIT_SYSTEM" = sysvinit ] || fatal "install_init_script: This operating system does not support sysvinit"

	local file="$1"

	debug "Installing '$file' as an init script"
	cp "$file" "$TARGET"/etc/init.d/
	chmod 0755 "$TARGET"/etc/init.d/"$(basename "$file")"
	run_in_target chkconfig --add "$(basename "$file")" >/dev/null
}

# Because 'yum install' is capable of accepting a filename to install,
# we simply echo the filename we were given if we can find a package
# that provides it.
find_package_containing() {
	run_in_target yum whatprovides "$1" | grep -iq '^no matches found' || echo "$1"
}

expand_command_path() {
	echo {/usr,}/{s,}bin/"$1" /usr/libexec/"$1"
}

install_kernel() {
	install_packages_in_target kernel
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
