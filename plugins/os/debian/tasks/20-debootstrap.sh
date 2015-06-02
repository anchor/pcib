case "$INIT_SYSTEM" in
	systemd)
		# systemd systems need dbus to boot properly.
		include_args=(--include dbus)
		;;
	sysvinit)
		include_args=()
		;;
esac

if ! debootstrap  \
	--arch "${OPTS[arch]}" \
	"${include_args[@]}" \
	"$release_name" \
	"$TARGET" \
	"${OPTS[debootstrap-mirror]}" |& \
	tee "$WORKSPACE"/debootstrap_output |
	spin "Running debootstrap"
then
	error "Debootstrap failed:"
	cat "$WORKSPACE"/debootstrap_output
	exit 1
fi
