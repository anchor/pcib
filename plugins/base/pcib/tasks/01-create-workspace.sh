# Create a temporary "scratch-space" in which the build process can store files.
cleanup_workspace() {
	if [ -z "$BUILD_COMPLETE" -o "$DEBUG" = y ]; then
		info "Preserving workspace ${WORKSPACE} for debugging"
	else
		rm -rf "$WORKSPACE"
		unset WORKSPACE
	fi
}

register_cleanup "cleanup_workspace"

WORKSPACE="$(mktemp -d -t pcib.XXXXXXXXXX)"

TARGET="${WORKSPACE}/target"

mkdir "$TARGET"
