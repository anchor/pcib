# Usage-printing functions for PCIB.
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

# Register a function to be called when the `usage` function is called.
#
# Usage:
#
#    register_usage <functionname>
#
register_usage() {
	debug "Registering usage function $1"
	USAGE_FUNCTIONS+=("$1")
}

# Display a section name in usage output style
#
# Usage:
#
#    usage_section <name>
#
# For example, the call `usage_section Faff` will produce on stderr
# something like:
#
#    Faff help:
#
usage_section() {
	echo >&2
	echo >&2
	colourise "$1 help:" 3 0 4 >&2
	echo >&2
}

# Print the description for a section of usage information.
#
# Usage:
#
#    usage_description <sometext>
#
# This function strips leading whitespace and line-wraps to fit the terminal
# window, so feel free to line-wrap however you see fit.
#
usage_description() {
	refold "$1" >&2
	echo >&2
	echo >&2
}

# Display the help for an option.
#
# Usage:
#
#    usage_option <option> <summary> [moretext...]
#
# Renders the given <option>, with <summary> next to it, and any additional
# arguments on additional lines, aligned with the <summary> text.  To fit into
# an 80-line screen, <option> should be no more than 35 characters, and 
# <summary> and each [moretext] option should be no more than 40 characters.
#
# For example, if you called:
#
#    usage_option "--faff <faffage>" "Frobs the foobar" "More text" "Oh, and some more too"
#
# That would be rendered something like this:
#
#        --faff <faffage>              Frobs the foobar
#                                      More text
#                                      Oh, and some more too
#
usage_option() {
	opt="$1"
	summary="$2"
	shift 2
	
	echo -en "    $opt\t" >&2
	
	# Fark, text formatting is *annoying*
	optlen=$((${#opt}+13))
	
	while [[ $optlen < 40 ]]; do
		echo -en "\t" >&2
		optlen=$(($optlen+8))
	done
	
	colourise "$summary" 3 >&2
	
	while [ -n "$1" ]; do
		for i in $("$gseq" 1 $(($optlen / 8)) ); do
			echo -en "\t"
		done
		echo "$1"
		shift
	done
}

# Print usage information to stderr.
#
# Normally, this would be trivial.  For *us*, though, things are made a
# little more difficult by the fact that plugins can add their own command
# line options, and we'd like to be able to include those as well.
#
usage() {
	echo "PCIB: The Penultimate Cloud Image Builder" >&2
	echo >&2
	echo "Usage: $0 <options...>" >&2
	
	for fn in "${USAGE_FUNCTIONS[@]}"; do
		$fn >&2
	done
}

