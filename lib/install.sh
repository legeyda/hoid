

shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/install.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/scope.sh



hoid_lib_install() {
	unset hoid_lib_install_name hoid_lib_install_destdir hoid_lib_install_data

	while bobshell_isset_1 "$@"; do
		case "$1" in
			(-n|--name)
				hoid_lib_install_name="$2"
				shift 2
				;;

			(-d|--dest-dir)
				hoid_lib_install_destdir="$2"
				shift 2
				;;


			(-*)
				bobshell_die "hoid_lib_install: unrecognized option: $1"
				;;

			(*)
				hoid_lib_install_data="$1"
				if bobshell_isset_2 "$@"; then
					bobshell_die 'hoid_lib_install: extra argument'
				fi
				set --
				break
		esac
	done

	bobshell_require_isset hoid_lib_install_name       missing name
	bobshell_require_isset hoid_lib_install_data       missing data
	

	bobshell_scope_unset BOBSHELL_INSTALL_
	BOBSHELL_INSTALL_NAME="$hoid_lib_install_name"
	if bobshell_isset hoid_lib_install_destdir; then
		BOBSHELL_INSTALL_DESTDIR="$hoid_lib_install_destdir"
	fi
	bobshell_install_init
	bobshell_install_put_executable "$hoid_lib_install_data" "$hoid_lib_install_name"

}