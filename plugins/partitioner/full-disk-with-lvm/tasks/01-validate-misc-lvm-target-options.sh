if ! optval vgname >/dev/null; then
	fatal "--vgname must be specified"
fi

if ! optval lvname >/dev/null; then
	fatal "--lvname must be specified"
fi
