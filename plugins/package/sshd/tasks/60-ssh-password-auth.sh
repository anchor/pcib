if [ -n "$permit_root_login" ]; then
	"$gsed" -i "s/^PermitRootLogin without-password\$/PermitRootLogin $permit_root_login/" "$TARGET"/etc/ssh/sshd_config
fi
