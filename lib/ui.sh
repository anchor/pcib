# Functions for interacting with the user.
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

# Display a fatal error and exit.
#
# Usage:
#
#    fatal <string> [exit code]
#
# <string> is the string to display, while [exit code], if set, sets the
# exit code to use (defaults to 1)
#
fatal() {
	log "FATAL: $1"
	colourise "$(refold "FATAL ERROR: $1")" 1 >&2
	exit "${2:-1}"
}

# Display an error.
#
# Usage:
#
#    error <string>
#
error() {
	log "ERROR: $1"
	colourise "$(refold "ERROR: $1")" 1 >&2
}

# Display a warning message.
#
# Usage:
#
#    warning <string>
#
warning() {
	log "WARN:  $1"
	colourise "$(refold "WARNING: $1")" 3 >&2
}

# Display an informational message.
#
# Usage:
#
#    info <string>
#
info() {
	log "INFO:  $1"
	colourise "$(refold "INFO: $1")" 6 >&2
}

# Print a debug message if the user has enabled debugging (--debug)
#
# Usage:
#
#    debug <string>
#
debug() {
	log "DEBUG: $1"
	if [ "$DEBUG" = "y" ]; then
		colourise "$(refold "DEBUG: $1")" 5 0 1 >&2
	fi
}

# Produce a progress spinner that moves every time a line of text is fed into it.
#
# Usage:
#
#    some_command | spin "Doing something"
#
# This will first print "Doing something: ", and then print a small ASCII
# spinner which will rotate one position every time a line of text is output
# by `some_command`.
#
spin() {
	local job_desc="$1"
	local cursor="|"

	echo -n "$job_desc: " >&2

	echo -n "$(colourise "$cursor" 3)" >&2
	echo -en "\010" >&2

	while read line; do
		case $cursor in
			"|") cursor="/";;
			"/") cursor="-";;
			"-") cursor="\\";;
			"\\") cursor="|";;
		esac

		echo -n "$(colourise "$cursor" 3)" >&2
		echo -en "\010" >&2
	done < <(logtee "$1")

	colourise "done!" 2 0 1 >&2
}


# Colourise a string.
#
# Takes a string, foreground and background colour values, and a "bold"
# flag, and prints the string wrapped in ANSI colour sequences, if stdout is
# a terminal.
#
# In general, you shouldn't need to call this function too much directly in
# your tasks; there are plenty of wrapper functions available which should
# be used.
#
# Usage:
#
#    colourise [-n] <string> <fgcolour> [bgcolour] [style]
#
# <string> is any string.
#
# <fgcolour> is one of:
#    - 0 black, or grey if bolded
#    - 1 red
#    - 2 green
#    - 3 yellow
#    - 4 blue
#    - 5 magenta (aka "purple" for normal people)
#    - 6 cyan (aka "light blue")
#    - 7 white
#
# [bgcolour] is optional (defaults to 0), and takes the same values as
#    <fgcolour>.
#
# [style] is optional (defaults to 0), and can be either 0 (normal), 1
# (bold), or 4 (underline).
#
# If [-n] is specified (it *must* be the first option, if provided), the
# string will be printed without any trailing newline.
#
colourise() {
	if [ "$1" = "-n" ]; then
		local escopts="-en"
		local noescopts="-n"
		shift
	else
		local escopts="-e"
		local noescopts=""
	fi
	
	local str="$1"
	local fgc=$((30+$2))
	local bgc=$((40+${3:-0}))
	local bold=$((30+${4:-0}))
	
	if [ -t 1 ]; then
		echo $escopts "\033[${bold};${bgc};${fgc}m${str}\033[0m"
	else
		echo $noescopts "$str"
	fi
}

# Take an arbitrary chunk of text and turn it into a single paragraph of
# 80-column hard-wrapped text.  It strips out all leading whitespace from each
# line of input, and then reflows the whole thing so it comes out looking
# all neat and tidy.
#
# Usage:
#
#    refold <string>
#
refold() {
	echo "$1" | sed 's/^[[:space:]]*//' | tr '\n' ' ' | fold -s -w 80
}

# Write a timestamped log message to the build log.
#
# Usage:
#
#    log <string>
#
log() {
	if [ -n "$WORKSPACE" ]; then
		echo "$(date '+%F %T') $1" >>"${WORKSPACE}/build.log"
	fi
}

# Log pipe output.  Specify the name of the program, or some other useful
# identifier, as the argument to this function.
#
# Usage:
#
#    some-program | logpipe "some program"
#
# This will log the start and end times of the some-program run, and dump
# everything that some-program outputs into the log file, neatly delineated
# so you know exactly what happened.
#
# Note that if you want to catch stderr as well, you'll need to handle it
# yourself, like this:
#
#    some-stderr-program 2>&1 | logpipe "some stderr program"
#
logpipe() {
	if [ -n "$WORKSPACE" ]; then
		log "$1 start -----8<-----"
		cat >>"${WORKSPACE}/build.log"
		log "$1  end  ----->8-----"
	fi
}

# Log pipe output, while passing the program output through to stdout again.
# Otherwise, the calling conventions and behaviour of this function mirror
# that of `logpipe`.
#
# Usage:
#
#    some-program | logtee "some program"
#
logtee() {
	if [ -n "$WORKSPACE" ]; then
		log "$1 start -----8<-----"
		tee -a "${WORKSPACE}/build.log"
		log "$1  end  ----->8-----"
	fi
}
