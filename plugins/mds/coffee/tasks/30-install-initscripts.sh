cp -rT "$(plugin_file mds/coffee usr/local/share/avf)" "$TARGET"/usr/local/share/avf

if [ "$INIT_SYSTEM" = systemd ]; then
	install_systemd_unit "$(plugin_file mds/coffee systemd/avf-connect-to-mds.service)"
fi

for service in \
"avf-configure-networking" \
"avf-install-root-ssh-keys" \
"avf-set-root-password"; do
	case "$INIT_SYSTEM" in
		systemd)
			install_systemd_unit "$(plugin_file mds/coffee systemd/${service}.service)" enable
			;;
		sysvinit)
			install_init_script "$(plugin_file mds/coffee init_scripts/${service})"
			;;
		*)
			fatal "Unsupported init system: $INIT_SYSTEM"
			;;
	esac
done
