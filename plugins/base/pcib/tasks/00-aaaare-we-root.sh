if [ "$UID" != "0" ]; then
	fatal "Root privileges are required to build an image."
fi
