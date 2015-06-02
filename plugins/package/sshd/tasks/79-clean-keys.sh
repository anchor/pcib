(
	shopt -s nullglob
	for k in "$TARGET"/etc/ssh/ssh_host_*_key{,pub}; do
		if ! "$gshred" --remove "$k" >/dev/null; then
			fatal "Error removing '$k' from the image."
		fi
	done
)
