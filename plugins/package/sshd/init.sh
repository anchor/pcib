package_sshd_usage() {
	usage_section "sshd"

	usage_description \
		"This plugin installs and configures the OpenSSH server for"     \
		"remote login."

	usage_option "permit-root-login" \
		"An optional setting for the PermitRootLogin option in"          \
		"sshd_config. If unspecified, will be left as the default. Note" \
		"that mds plugins may override this based on instance metadata"  \
		"at boot time."
}

register_usage package_sshd_usage

parseopt permit-root-login true
permit_root_login="$(optval permit-root-login)" || :
case "$permit_root_login" in
	""|yes|without-password|no) ;;
	*) fatal "Invalid value for permit-root-login: $permit_root_login" ;;
esac
