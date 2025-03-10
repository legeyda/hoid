
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/unstable/url.sh
shelduck import ./install/docker.sh

hoid_task_install() {
	hoid_task_subcommand hoid_task_install "$@"
}

# hoid_util_subcommand BASECMD SUBCMD ARGS
hoid_util_subcommand() {
	_hoid_task_subcommand__function="${1}_${2}"
	if ! bobshell_command_available "$_hoid_task_subcommand__function"; then
		bobshell_die "hoid_task_install: unknown subcommand: $1"
	fi
	shift 2
	"$_hoid_task_subcommand__function" "$@"
	unset _hoid_task_subcommand__function
}

hoid_task_install_shelduck() {
	hoid_task_install_shelduck_installer=$(shelduck resolve https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/install.sh)
	hoid script "$hoid_task_install_shelduck_installer"
	unset hoid_task_install_shelduck_installer
}

hoid_task_install_hoid() {
	bobshell_die 'not implemented'
	hoid_task_install_hoid_installer=$(shelduck resolve https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh)
	hoid script "$hoid_task_install_hoid_installer"
	unset hoid_task_install_hoid_installer
}

