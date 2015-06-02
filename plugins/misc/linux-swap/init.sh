misc_linux_swap_usage() {
	usage_section "Linux swap"

	usage_description \
		"This plugin creates a Linux swap volume."

	usage_option "--swap-size" \
		"Specify the size of the swap partition. Standard suffixes are"  \
		"(M, G, etc.) are supported. (default: 512M)"
}

# Inform partitioning plugins that we want a swap partition.
WANT_SWAP=y

parseopt swap-size true 512M
SWAP_SIZE="$(optval swap-size)"
