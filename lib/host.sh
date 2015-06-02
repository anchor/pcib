# Host support functions for PCIB.
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

# Ensure that a program is available.
#
# In order to be able to successfully build an image, many programs must be available.
# On a random user's system, there's no guarantee that all of those programs will
# be available already. So, we need to do two things:
#
# 1. Try and work out if the program *is* available already (ie it's
#    installed on the system);
#
# 2. Whether that program will do what we need it to (namespace collisions
#    and out-of-date versions are a PITA).
#
# This function handles both of those things.
#
# Usage:
#
#    check_program_available <testcmd> <filename>
#
# The function will execute `<testcmd>`, and if that returns true (0), the
# command will be deemed "available" and we'll return successfully.  If
# `<testcmd>` returns false, then we'll count it as "not available".  All
# output from `<testcmd>` will be redirected to /dev/null.  Feel free to
# have your `<testcmd>` try to run the program with `--help` and grep for
# needed options, etc if necessary.
#
check_program_available() {
	local testcmd="$1"
	local filename="$2"

	debug "Checking if '$filename' is available by running '$testcmd'"

	if eval "$testcmd" >/dev/null 2>&1; then
		debug "'$filename' is available and looks good"
		return 0
	fi

	fatal "'$filename' is not available; cannot proceed with build."
}

run_in_target() {
	chroot "$TARGET" "$@"
}
