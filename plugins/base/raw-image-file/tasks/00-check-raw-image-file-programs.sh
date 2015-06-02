case "$compress" in
	bzip2) check_program_available "bzip2 --help" "bzip2" ;;
esac

case "$FILESYSTEM" in
	ext*)
		check_program_available "(zerofree || true) |& grep 'usage: zerofree'" zerofree
		;;
esac
