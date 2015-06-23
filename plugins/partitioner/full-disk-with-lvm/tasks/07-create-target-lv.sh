cleanup_lvm() {
	vgchange -an "$(optval vgname)" &>/dev/null
	unlock "$lvm_lock"
}

debug "Loopback device is $BLOCK_DEVICE"

pvcreate "${PARTITIONS[/]}" |& logpipe "pvcreate"

# Avoid trying to build multiple images with the same VG name
# simultaneously.
lvm_lock="lvm:$(optval vgname)"
lock "$lvm_lock"

register_cleanup cleanup_lvm
vgcreate "$(optval vgname)" "${PARTITIONS[/]}" |& logpipe "vgcreate"

lvcreate -L "$(optval lvsize)" -n "$(optval lvname)" \
	"$(optval vgname)" |& logpipe "lvcreate root"

# Has another plugin requested a place to mkswap?
if [ "$WANT_SWAP" = y ]; then
	lvcreate -L "$SWAP_SIZE" -n swap "$(optval vgname)" \
		|& logpipe "lvcreate swap"
	SWAP_DEVICE="$(lvm_device_path "$(optval vgname)" swap)"
fi

declare -A PARTITIONS
PARTITIONS[/]="$(lvm_device_path "$(optval vgname)" "$(optval lvname)")"
