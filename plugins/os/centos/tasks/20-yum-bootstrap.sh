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

cleanup_yum_bootstrap() {
	[ -z "$yum_repos_file" ] || rm -f "$yum_repos_file"
	[ -z "$yum_repos_base" ] || rm -rf "$TARGET"/var/cache/yum/"$yum_repos_base"*
}

register_cleanup cleanup_yum_bootstrap

yum_repos_file="$(mktemp /etc/yum/repos.d/centos-"$release_version"-XXXX.repo)"
yum_repos_base="$(basename "$yum_repos_file" | sed 's/\.repo$//')"

cat >"$yum_repos_file" <<EOF
[$yum_repos_base-base]
name=$yum_repos_base-base
baseurl=$(optval mirror)/$release_version/os/$(optval arch)/
enabled=0

[$yum_repos_base-updates]
name=$yum_repos_base-updates
baseurl=$(optval mirror)/$release_version/updates/$(optval arch)/
enabled=0
EOF

# /var/run needs to be a symlink to /run on CentOS >= 7.
if [ "$release_version" -ge 7 ]; then
	# Some (old) versions of yum will create all parent directories of
	# the yum lockfile regardless.
	mkdir -p "$TARGET"/var "$TARGET"/run ||
		fatal "Unable to ensure /var and /run exist"
	ln -sfn ../run "$TARGET"/var/run ||
		fatal "Unable to ensure /var/run -> /run"
fi

if ! yum -y install                                       \
	/usr/bin/yum                                           \
	/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-"$release_version" \
	--installroot="$TARGET"                                \
	--enablerepo="$yum_repos_base"-base                    \
	--enablerepo="$yum_repos_base"-updates                 |&
	tee "$WORKSPACE"/yum_output                            |
	spin "Bootstrapping yum (phase 1)"
then
	error "Yum bootstrap phase 1 failed:"
	cat "$WORKSPACE"/yum_output
	exit 1
fi

run_cleanups cleanup_yum_bootstrap
