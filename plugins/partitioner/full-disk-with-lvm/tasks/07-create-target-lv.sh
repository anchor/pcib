cleanup_lvm() {
	vgchange -an "$vgname" &>/dev/null
	# Give udev time to react.
	sleep 1
}

debug "Loopback device is $BLOCK_DEVICE"

pvcreate "${PARTITIONS[/]}" |& logpipe "pvcreate"

# In order to allow multiple image builds to run simultaneously, use a
# random temporary VG name for the build. We'll rename it to
# $(optval vgname) later, in a brief serialised portion of the build.
vgname="$(mktemp -u pcib.XXXXXX)"

register_cleanup cleanup_lvm
vgcreate "$vgname" "${PARTITIONS[/]}" |& logpipe "vgcreate"

lvcreate -L "$(optval lvsize)" -n "$(optval lvname)" \
	"$vgname" |& logpipe "lvcreate root"

# Has another plugin requested a place to mkswap?
if [ "$WANT_SWAP" = y ]; then
	lvcreate -L "$SWAP_SIZE" -n swap "$vgname" \
		|& logpipe "lvcreate swap"
	SWAP_DEVICE="$(lvm_device_path "$vgname" swap)"
fi

declare -A PARTITIONS
PARTITIONS[/]="$(lvm_device_path "$vgname" "$(optval lvname)")"
