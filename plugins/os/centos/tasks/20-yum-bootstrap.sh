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

# /var/run needs to be a symlink to /run on CentOS >= 7.
if [ "$release_version" -ge 7 ]; then
	# Some (old) versions of yum will create all parent directories of
	# the yum lockfile regardless.
	mkdir -p "$TARGET"/var "$TARGET"/run ||
		fatal "Unable to ensure /var and /run exist."
	ln -sfn ../run "$TARGET"/var/run ||
		fatal "Unable to ensure /var/run -> /run."
fi

if ! yum -y install                                       \
	/usr/bin/yum                                           \
	/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-"$release_version" \
	/etc/redhat-release                                    \
	--installroot="$TARGET"                                \
	"${yum_repos_args[@]}"                                 |&
	tee "$WORKSPACE"/yum_output                            |
	spin "Bootstrapping yum"
then
	error "Yum bootstrap failed:"
	cat "$WORKSPACE"/yum_output
	exit 1
fi

run_cleanups cleanup_yum_bootstrap

# Older versions of rpm expect bits of the rpm database to use a
# different format. Rebuild the database on older CentOS to avoid
# problems later.
if [ "$release_version" -lt 7 ]; then
	run_in_target rpm --rebuilddb 2>&1 | logpipe "rpm --rebuilddb" ||
		fatal "Error rebuilding RPM database."
fi
