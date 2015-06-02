cleanup_disable_daemons() {
	rm -f "$TARGET"/usr/sbin/policy-rc.d
}

register_cleanup cleanup_disable_daemons

mkdir -p "$TARGET"/usr/sbin
cat >"$TARGET"/usr/sbin/policy-rc.d <<EOF
#!/bin/sh

exit 101
EOF
chmod 0755 "$TARGET"/usr/sbin/policy-rc.d
