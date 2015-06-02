if [ -z "$SWAP_DEVICE" ]; then
	fatal "No swap device provided by a partitioning plugin"
fi

if ! mkswap -f "$SWAP_DEVICE" &>/dev/null; then
	fatal "Unable to format device $SWAP_DEVICE as swap"
fi
