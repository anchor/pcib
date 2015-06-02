# This is completely unnecessary on OpenBSD, where /etc/rc will already
# create these keys at boot time if they don't exist.
if [ "${OPTS[os]}" != openbsd ]; then
	case "$INIT_SYSTEM" in
		systemd)
			install_systemd_unit "$(plugin_file package/sshd systemd/generate-ssh-hostkeys.service)" enable
			;;
		sysvinit)
			install_init_script "$(plugin_file package/sshd init_scripts/generate-ssh-hostkeys)"
			;;
		*)
			fatal "Unsupported init system: $INIT_SYSTEM"
			;;
	esac
fi
