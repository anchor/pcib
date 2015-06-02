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

case "${OPTS[os]}" in
	openbsd)
		cat >>"$TARGET"/etc/rc.firsttime <<-'EOF'
			echo -n "fetching hostname from mds: "
			hostname="$(ftp -Vo- http://169.254.169.254/2009-04-04/meta-data/local-hostname)"
			if [ -n "$hostname" ]; then
				echo "${hostname}."
				echo "$hostname" >/etc/myname
				hostname "$hostname"
			else
				echo "(none)."
			fi
			EOF

		ec2_user="${OPTS[ec2-user]}"
		case "$ec2_user" in
			"") ;;
			*)
				userinfo="$(run_in_target getent passwd "$ec2_user")" ||
					die "No such user: $ec2_user"
				userhome="$(cut -d: -f6 <<<"$userinfo")"
				mkdir -p "$TARGET"/"$userhome"/.ssh
				run_in_target chown "$ec2_user": "$userhome"/.ssh

				cat >>"$TARGET"/etc/rc.firsttime <<-EOF
					pubkey_base=http://169.254.169.254/2009-04-04/meta-data/public-keys
					echo -n "fetching authorized keys for ${ec2_user}:"
					keys="\$(ftp -Vo- "\$pubkey_base"/ | cut -d= -f1)"
					for key in \$keys; do
						echo -n .
						key="\$(ftp -Vo- "\$pubkey_base"/"\$key"/openssh-key)"
						echo "\$key" >>$userhome/.ssh/authorized_keys
					done
					chown $ec2_user: $userhome/.ssh/authorized_keys
					echo " done."
					EOF
				;;
		esac
		;;
	*)
		die "Unsupported operating system: ${OPTS[os]}"
		;;
esac
