
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/cmd/mktemp.sh

hoid_task_install() {
	case "$1" in
		(shelduck|hoid)
			hoid_task_install_subcommand="$1"
			shift
			"hoid_task_install_$hoid_task_install_subcommand" "$@"
			unset hoid_task_install_subcommand
			;;
		(*)
			bobshell_die "hoid install: subcommand '$1' not supported"
			;;
	esac
}


hoid_task_install_shelduck() {
	hoid_task_install_shelduck_installer=$(shelduck resolve https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh)
	hoid script "$hoid_task_install_shelduck_installer"
	unset hoid_task_install_shelduck_installer
}

hoid_task_install_hoid() {
	hoid_task_install_hoid_installer=$(shelduck resolve https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh)
	hoid script "$hoid_task_install_hoid_installer"
	unset hoid_task_install_hoid_installer
}
