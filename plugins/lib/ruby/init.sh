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

# Ruby packaging is a mess.
#
# * CentOS packages Ruby gems in sitelibdir.
# * Debian places Ruby gems in vendordir (*not* vendorlibdir, except
#   for native code).
# * Older versions of Debian just dumped them into rubylibdir.
# * The most general way to do this is to just try each of rubylibdir,
#   vendordir, vendorlibdir, sitedir and sitelibdir, and hope we match
#   on one of those. If not, install_package_containing will barf and
#   we'll get a build failure.

# _set_rubydirs: Run once, when install_ruby_package_containing is
# first called, to set some variables with the location of the guest's
# various Ruby library directories. We can't do this at plugin load
# time, because the guest isn't bootstrapped yet, but we still want to
# call it only once to avoid excessive chrooting to ask the guest for
# the same information over and over.
_set_rubydirs() {
	install_package_providing ruby
	ruby_rubylibdir="$(run_in_target ruby -rrbconfig -e 'print RbConfig::CONFIG["rubylibdir"]')"
	ruby_vendordir="$(run_in_target ruby -rrbconfig -e 'print RbConfig::CONFIG["vendordir"]')"
	ruby_vendorlibdir="$(run_in_target ruby -rrbconfig -e 'print RbConfig::CONFIG["vendorlibdir"]')"
	ruby_sitedir="$(run_in_target ruby -rrbconfig -e 'print RbConfig::CONFIG["sitedir"]')"
	ruby_sitelibdir="$(run_in_target ruby -rrbconfig -e 'print RbConfig::CONFIG["sitelibdir"]')"
}

# install_ruby_package_containing: Given a relative path to a Ruby
# library file, find and install a package which provides this library
# in one of Ruby's plethora of library paths.
install_ruby_package_containing() {
	[ -n "$ruby_rubylibdir" ] || _set_rubydirs
	file="$1"

	case "${OPTS[os]}" in
		centos)
			# Special case to handle CentOS's weird rubygems packaging.
			if install_packages_in_target /usr/share/gems/gems/'*'/lib/"$file"; then
				return 0
			fi
			;;
		*)
			;;
	esac

	install_package_containing \
		"$ruby_rubylibdir"/"$file" \
		"$ruby_vendordir"/"$file" \
		"$ruby_vendorlibdir"/"$file" \
		"$ruby_sitedir"/"$file" \
		"$ruby_sitelibdir"/"$file"
}
