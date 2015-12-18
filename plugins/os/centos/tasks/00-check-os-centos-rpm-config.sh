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

# Some distributions (e.g., Debian) patch rpm to use a database
# elsewhere than /var/lib/rpm by default. This causes yum to bootstrap
# CentOS with its rpm database in the wrong place, causing the new OS
# to believe that it has no packages installed.
#
# Since there's no way to override an rpm macro through yum, fail hard
# if %_dbpath is set to something unexpected.

rpm_dbpath="$(rpm -E %_dbpath)"

[ "$rpm_dbpath" = /var/lib/rpm ] ||
	fatal "RPM database is $rpm_dbpath (must be /var/lib/rpm)."
