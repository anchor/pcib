if [ -f "$TARGET"/etc/resolv.conf ]; then
	shred --remove "$TARGET"/etc/resolv.conf
fi

if [ -f "$TARGET"/root/.bash_history ]; then
	shred --remove "$TARGET"/root/.bash_history
fi

rm -rf "$TARGET"/tmp/* "$TARGET"/run/*
find "$TARGET"/var/log -type f -print0 | xargs -0 --no-run-if-empty shred --remove
