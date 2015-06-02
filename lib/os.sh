# Copyright (c) 2015 Anchor Systems Pty Ltd <support@anchor.com.au>
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

# Once upon a time, these were implemented by individual OS plugins.
# However, the majority of their code was simply duplicated between
# plugins. In order to reduce the inevitable code smell, the
# OS-specific bits were separated into two new (trivial) functions,
# find_package_containing and expand_command_path, and the common code
# moved here.

install_package_containing() {
	# Run cheap tests first; if a file we want already exists, we can
	# skip all of the below (and apt-file is sloooooowwwww). This is
	# also more correct; if we are provided with more than one file, and
	# one of them (other than the first) already exists, there's no
	# point trying to install *another* package to provide an
	# alternative for something we already have.
	for file in "$@"; do
		debug "Checking to see if '$file' already exists"
		[ -e "$TARGET""$file" ] || continue
		debug "File exists, not installing any packages: $file"
		return 0
	done

	for file in "$@"; do
		debug "Looking for a package containing '$file'"
		pkg="$(find_package_containing "$file")"

		if [ -n "$pkg" ]; then
			install_packages_in_target "$pkg"
			return 0
		fi
	done

	error "No package found for any of: $*"
	return 1
}

install_package_providing() {
	for cmd in "$@"; do
		debug "Looking for a package providing command '$cmd'"
		if install_package_containing $(expand_command_path "$cmd"); then
			return 0
		fi
	done

	error "No package found for any of commands: $*"
	return 1
}
