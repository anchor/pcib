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
yum_repos_args=()

# Other plugins which need to inject additional repos to be present at
# bootstrap time should call this function in a hook with priority 19.
add_bootstrap_yum_repo() {
	local name="$1"
	local url="$2"
	local prio="$3"

	[ -n "$name" ] || fatal "A yum repo needs a name."
	[ -n "$url" ]  || fatal "A yum repo needs a URL."

	yum_repos_args+=(--enablerepo="$yum_repos_base"-"$name")

	cat >>"$yum_repos_file" <<-EOF
		[$yum_repos_base-$name]
		name=$yum_repos_base-$name
		baseurl=$url
		enabled=0
		EOF

	[ -z "$prio" ] || echo "priority=$prio" >>"$yum_repos_file"
	echo >>"$yum_repos_file"
}

add_bootstrap_yum_repo base \
	"$(optval mirror)"/"$release_version"/os/"$(optval arch)/"
add_bootstrap_yum_repo updates \
	"$(optval mirror)"/"$release_version"/updates/"$(optval arch)/"
