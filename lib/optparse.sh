# Command-line option parsing functions for PCIB.
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

# Dig through the morass of command-line options we were passed to find the
# specified option.
#
# Option parsing in PCIB is a little... arcane.  The problem is that we
# don't know, before we start peering at command line options, what options
# are going to be valid, and so we can't just wave `getopt`(1) over $@ and
# expect to get useful results.
#
# Instead, we pull individual options out of the argument array (as stored
# in ARGV) as they're requested by plugins by calling this function, like
# this:
#
# Usage:
#
#    parseopt <optname> [hasvalue] [default]
#
# <optname> is the part of the command-line option *after* the double dash.
# [hasvalue] is an optional parameter (defaults to "false") which must be
# one of the strings "true" or "false".  This indicates to parseopt whether
# or not the next command-line argument after the option parameter (if
# found) should be taken as being a value for this option.
#
# If the specified <optname> is found in the unparsed command line
# arguments, then it will be removed from the list of unparsed command-line
# arguments, its value will be taken as being the next argument (if one was
# requested), and the value will be stored in OPTS[<optname>].  If
# [hasvalue] is "false", then OPTS[<optname>] will be set to "y".
#
# If the specified <optname> was *not* found and [hasvalue] is "true", then
# OPTS[<optname>] will be unset if no [default] was specified, or else will
# be set to [default].  If [hasvalue] is "false", then OPTS[<optname>] will
# be set to "n".
#
# Note that this function can be invoked multiple times for the one
# <optname>.  Each time it is invoked, it will go looking for a new instance
# of --<optname> in the unparsed command-line arguments, and if there are no
# more instances available, it will unset/default OPTS[<optname>].  Be
# careful!
#
parseopt() {
	local optname="$1"
	local hasvalue="${2:-false}"
	local default="$3"

	debug "parseopt($optname, $hasvalue)"

	if [ "$hasvalue" != true -a "$hasvalue" != false ]; then
		fatal "Unknown value for 'hasvalue' ($hasvalue) in parseopt for '$optname'.  Please file a bug."
	fi

	if [ -z "$optname" ]; then
		fatal "No option name passed to parseopt.  Please file a bug."
	fi

	unset OPTS[$optname]

	for i in $("$gseq" 0 $((${#ARGV[@]}-1))); do
		if [ "${ARGV[$i]}" = "--$optname" ]; then
			unset ARGV[$i]

			if [ "$hasvalue" = true ]; then
				OPTS[$optname]="${ARGV[$(($i+1))]}"
				unset ARGV[$(($i+1))]

				if [ -z "${OPTS[$optname]}" ]; then
					fatal "No value provided for --${optname}."
				fi

				debug "Value found for --$optname: ${OPTS[$optname]}"
			else
				OPTS[$optname]=y
			fi

			# Reset the array indexes so we can iterate through
			# it again next time
			ARGV=("${ARGV[@]}")

			debug "Remaining unparsed arguments: '${ARGV[*]}'"

			return 0
		fi
	done

	# This option wasn't provided on the command line, so check if it
	# exists in a config file.
	for i in $("$gseq" 0 $((${#CONFIG_ARGV[@]}-1))); do
		if [ "${CONFIG_ARGV[$i]}" = --"$optname" ]; then
			unset CONFIG_ARGV[$i]

			if [ "$hasvalue" = true ]; then
				OPTS[$optname]="${CONFIG_ARGV[$(($i+1))]}"
				unset CONFIG_ARGV[$(($i+1))]

				if [ -z "${OPTS[$optname]}" ]; then
					fatal "No value provided for '${optname}' in config file '$(optval config)'."
				fi

				debug "Value found for '$optname' in config file '$(optval config)': ${OPTS[$optname]}"
			else
				OPTS[$optname]=y
			fi

			# Reset the array indexes so we can iterate through
			# it again next time
			CONFIG_ARGV=("${CONFIG_ARGV[@]}")

			debug "Remaining unparsed config parameters: '${CONFIG_ARGV[*]}'"

			return 0
		fi
	done

	# We didn't find it... bummer
	if [ "$hasvalue" = "true" ]; then
		if [ -n "$default" ]; then
			OPTS[$optname]="$default"
		fi
	else
		OPTS[$optname]=n
	fi
}

# Return the value of the given (already parsed) command-line option.
#
# Once a command-line option has been parsed (by calling `parseopt <name>`),
# you can then extract the value (if one was given), or test for the
# presence of the option, by calling this function.
#
# Usage:
#
#    optval <optname>
#
# This function will return 0 (true) if the option with the specified name
# exists and has been parsed, or 1 (false) otherwise.  Also, any value that
# was stored for the option will be echoed out.
#
optval() {
	local optname="$1"

	debug "optval($optname)"

	# This is one fucked-up way of asking, "does this key exist in the
	# hash?".  Read the "Parameter expansion" section of the bash manpage
	# *really* carefully, keeping an eye out for the word "colon".
	if [ "${OPTS[$optname]+x}" ]; then
		debug "=> ${OPTS[$optname]}"
		echo "${OPTS[$optname]}"
		return 0
	else
		return 1
	fi
}
