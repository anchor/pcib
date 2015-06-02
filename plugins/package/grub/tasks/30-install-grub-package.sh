case "${OPTS[os]}" in
	debian)
		# Because Debian has multiple packages that provide grub-install,
		# and because the one of those packages that we *want* is
		# grub2-common (which doesn't provide all of GRUB), we have to be
		# a bit picky about specific package names here instead of just
		# letting install_package_providing do its thing.
		install_packages_in_target grub-pc
		;;
	centos)
		# CentOS 7 is in a similar boat to Debian, having both grub2 and
		# grub2-tools. Older CentOSen still use GRUB 1.
		install_packages_in_target grub2 || install_package_providing grub-install
		;;
	*)
		install_package_providing grub-install
		;;
esac
