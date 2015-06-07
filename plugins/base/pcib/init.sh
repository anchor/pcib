# Copyright (c) 2015 Steven McDonald <steven@steven-mcdonald.id.au>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

base_pcib_usage() {
	usage_section "PCIB: The Penultimate Cloud Image Builder"
	usage_description "A flexible, extensible cloud image builder."

	usage_option "--basedir <directory>" \
		"The directory to use for all storage, including final images. pcib may"   \
		"do whatever it likes in this directory, so it should not be used by"      \
		"anything else. Default: /var/cache/pcib."

	usage_option "--config <file>" \
		"A config file to process additional options from. If only one argument"   \
		"provided to pcib, it will assume that it is a config file."

	usage_option "--debug" \
		"Enable debugging output."

	usage_option "--help" \
		"Display usage information and exit."

	usage_option "--os <os>" \
		"Required: The operating system to build, which may provide additional"    \
		"options."

	usage_option "--plugin <plugin>" \
		"Load a plugin, which may provide additional options. This option may be"  \
		"specified multiple times."
}

register_usage base_pcib_usage

parseopt basedir true /var/cache/pcib
BASEDIR="$(optval basedir)"
[ -d "$BASEDIR" ] || fatal "No such directory: $BASEDIR"
[ -r "$BASEDIR" ] || fatal "No read permission: $BASEDIR"
[ -w "$BASEDIR" ] || fatal "No write permission: $BASEDIR"
[ -x "$BASEDIR" ] || fatal "No search permission: $BASEDIR"
