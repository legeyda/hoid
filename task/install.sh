
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/string.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/base.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/misc/subcommand.sh
shelduck import https://raw.githubusercontent.com/legeyda/bobshell/refs/heads/main/url.sh

shelduck import ./install/_all.sh

bobshell_cli_setup hoid_task_install --var=hoid_task_install__destdir --param --default-value=         d destdir
bobshell_cli_setup hoid_task_install --var=hoid_task_install__bindir  --param --default-value=/opt/bin b bindir


hoid_task_install() {
	bobshell_cli_parse hoid_task_install "$@"
	shift "$bobshell_cli_shift"

	_hoid_task_install__function="hoid_task_install_${1}"
	if bobshell_command_available "$_hoid_task_install__function"; then
		shift
		"$_hoid_task_install__function" "$@"
	elif hoid_task_package_available "$1"; then # todo such conditions not working for now
		hoid_task_package_install "$@"
	else
		bobshell_die "hoid_task_install: unknown piece of software: $1"
	fi	
	unset _hoid_task_install__function
}

hoid_task_install_shelduck() {
	hoid script https://github.com/legeyda/shelduck/releases/latest/download/install.sh
}

hoid_task_install_hoid() {	
	bobshell_die 'not implemented'
	hoid_task_install_hoid_installer=$(shelduck resolve https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/shelduck.sh)
	hoid script "$hoid_task_install_hoid_installer"
	unset hoid_task_install_hoid_installer
}

