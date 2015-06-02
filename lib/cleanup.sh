# Cleanup module functions for PCIB.
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License version 3, as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, see <http://www.gnu.org/licences/>
#

# Register a new cleanup function
#
# A "cleanup function" is a function (or other script) which tidies things
# up after some part of the build has been done.  Any task which makes any
# sort of permanent change to the running system (like creating a file,
# mounting a filesystem, or whatever) MUST register a cleanup function to
# undo that at the end of the run.
#
# Registering a cleanup function is simple: you just define the function in
# the usual fashion, and then give the name of the function to
# `register_cleanup`, like this:
#
#    clean_me_up_scotty() {
#      rm -f "${workspace}/redshirt"
#    }
#    register_cleanup "clean_me_up_scotty"
#
# You should define and register your cleanup function at the beginning of
# your task script, before you do any work.  This is because, if your task
# script fails, the program will immediately run all registered cleanups and
# exit.  If you register your cleanup function *after* you do your work,
# it's possible that your task could say write a file, then fail before
# registering the cleanup function that was going to delete that file.  This
# would leave droppings all over the filesystem, and that's not cool.
#
# Cleanup functions are run in the reverse order of their registration, so
# you can assume that anything that a later task might have done (like, say,
# mounting a filesystem in an image that you created) has been undone before
# your cleanup function gets called (to, say, delete the image file).
#
# Note that your cleanup function may be called before your task script
# completes, so make sure that you don't *rely* on anything in particular
# being available to your cleanup function.  That means giving your `rm`
# calls a `-f`, for instance, so they don't cry if the file you ask them to
# delete isn't available.
#
# If you wish to do something different in the event that the build failed
# (such as leaving temporary files available to examine for debugging) you
# can check the BUILD_SUCCESS variable -- if the build completed
# successfully, then this variable will be set to "y", otherwise it will be
# unset.
#
register_cleanup() {
	debug "Registering cleanup function $1"
	CLEANUP_FUNCTIONS+=("$1")
	debug "Cleanup function list is now: ${CLEANUP_FUNCTIONS[*]}"
}

# Run the cleanup functions.
#
# Usage:
#
#    run_cleanups [upto]
#
# Cleanup functions are run in the reverse order they were registered (that
# is, the last one registered is the first one run, in the manner of a
# stack).  This is so that cleanups which require "later" work to be cleaned
# up first don't get all sad.  Consider the case of a block device being
# created, then a filesystem in that block device being mounted.  To clean
# it up, you have to unmount the filesystem before you can nuke the block
# device.
#
# There are situations in which you want to run a *partial* cleanup (say,
# you want to unmount filesystems, but not nuke block devices).  In that
# case, you can specify the name of a cleanup function in [upto], and then
# all cleanup functions that were defined after the specified function (and
# the specified function) will be executed in the proper order.
#
run_cleanups() {
	upto="$1"
	
	if [ -n "$upto" ]; then
		if ! echo "${CLEANUP_FUNCTIONS[*]}" | grep -q $upto; then
			fatal "Unknown cleanup function specified for upto: '$upto'"
		fi
	fi
	
	set +e
	
	while [ "${#CLEANUP_FUNCTIONS[@]}" -gt "0" ] && [ "${CLEANUP_FUNCTIONS[-1]}" != "$upto" ]; do
		# Worst.  Pop().  Ever.
		func="${CLEANUP_FUNCTIONS[-1]}"
		unset CLEANUP_FUNCTIONS[${#CLEANUP_FUNCTIONS[@]}-1]
		debug "Running cleanup function $func"
		$func
	done
	
	# The previous loop finished *before* running $upto, so we've got to do that separately
	if [ -n "$upto" ]; then
		unset CLEANUP_FUNCTIONS[${#CLEANUP_FUNCTIONS[@]}-1]
		debug "Running cleanup function $upto"
		$upto
	fi

	set -e
}
