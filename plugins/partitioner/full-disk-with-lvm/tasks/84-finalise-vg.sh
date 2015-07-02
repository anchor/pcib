# Ensure only one build at a time uses the $(optval vgname) VG.
lvm_lock="lvm:$(optval vgname)"
lock "$lvm_lock"

vgrename "$vgname" "$(optval vgname)" |& logpipe vgrename
vgname="$(optval vgname)"

run_cleanups cleanup_lvm
unlock "$lvm_lock"
