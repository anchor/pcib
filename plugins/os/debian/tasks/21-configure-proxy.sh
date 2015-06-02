cleanup_os_debian_proxy() {
	# Unconditionally remove the proxy configuration. For hosts we
	# manage, our configuration management will put it back, so there's
	# no loss there. For hosts we don't manage, this stands to cause
	# confusion for the customer if we leave it lying around.
	rm -f "$TARGET"/etc/apt/apt.conf.d/50proxy
}

register_cleanup cleanup_os_debian_proxy

if optval proxy >/dev/null; then
	echo "Acquire::http::Proxy \"$(optval proxy)\";" >"$TARGET"/etc/apt/apt.conf.d/50proxy
fi
